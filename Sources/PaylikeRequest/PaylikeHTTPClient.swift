import Foundation

/**
 * Responsible for sending out requests according to the Paylike API requirements
 */
public struct PaylikeHTTPClient {
    /**
     * Used for logging, called when the request is constructed
     */
    public var loggingFn: (Encodable) -> Void
    
    /**
     * Public initialization with default logging function
     */
    public init() {
        loggingFn = { obj in
            print("HTTP Client logger:", terminator: " ")
            debugPrint(obj)
        }
    }
    
    /**
     * Executes a request based on the endpoint and the optional request options
     */
    @available(swift 5.5)
    public func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions = RequestOptions()
    ) async throws -> PaylikeResponse {
        
        let request = try buildRequest(to: endpoint, withOptions: options)
        
        /**
         * Tries and executes async request and rethrow error
         */
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return PaylikeResponse(data: data, urlResponse: response)
        } catch {
            // @TODO: handle api errors? or just send up and catch it later?
            print(error.localizedDescription) //@TODO: is it antipattern to print here? probably is...
            throw error
        }
    }
    
    @available(swift, deprecated: 5.5, message: "Use async version if possible")
    public func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions = RequestOptions(),
        completion handler: @escaping (Result<PaylikeResponse, Error>) -> Void
    ) -> Void {
        do {
            let request = try buildRequest(to: endpoint, withOptions: options)
            /**
             * Executes request and returns `PaylikeResponse` or `error` or `PaylikeHTTPClientError.UnknownError`
             */
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let response = response else {
                    handler(.failure(PaylikeHTTPClientError.UnknownError))
                    return
                }
                handler(.success(PaylikeResponse(data: data, urlResponse: response)))
            }.resume()
        } catch {
            handler(.failure(error))
            return Void()
        }
    }
    
    private func buildRequest(
        to endpoint: URL,
        withOptions options: RequestOptions
    ) throws -> URLRequest {
        
        /**
         * Set the correct url based on
         * - endpoint
         * - options.query
         */
        var url = endpoint
        if let query = options.query {
            if (query.isEmpty) {
                throw PaylikeHTTPClientError.QueryIsEmpty
            }
            var queryItems: [URLQueryItem] = []
            query.forEach { key, value in
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw PaylikeHTTPClientError.InvalidBaseURL(url)
            }
            urlComponents.queryItems = queryItems
            guard let newUrl = urlComponents.url else {
                throw PaylikeHTTPClientError.UnknownError // @TODO: adequate error
            }
            url = newUrl
        }
        
        /**
         * Set the correct URLRequest fields based on
         * - url
         * - options
         */
        var request = URLRequest(url: url)
        if let timeoutInterval = options.timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        request.allHTTPHeaderFields = [
            "Accept-Version": String(options.version),
            "X-Client": options.clientId,
        ]
        request.httpMethod = options.httpMethod
        if let formFields = options.formFields {
            if formFields.isEmpty {
                throw PaylikeHTTPClientError.FormIsEmpty
            }
            let formBodyParts = formFields.reduce("") { prev, curr in
                let encodedValue = String(describing: curr.value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
                let keyValuePair = "\(curr.key)=\(encodedValue)"
                if prev.isEmpty {
                    return keyValuePair
                }
                return prev + "&" + keyValuePair
            }
            request.httpBody = Data(formBodyParts.data(using: .utf8)!)
            request.addValue(String(request.httpBody!.count), forHTTPHeaderField: "Content-Length")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        } else if let data = options.data {
            if (data.isEmpty) {
                throw PaylikeHTTPClientError.DataIsEmpty
            }
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        /**
         * Logging the request to be made
         */
        loggingFn(LoggingFormat(
            t: "Paylike HTTP Client request",
            url: url.absoluteString,
            method: request.httpMethod!,
            timeout: String(request.timeoutInterval),
            formFields: options.formFields,
            headers: request.allHTTPHeaderFields!
        ))
        
        return request
    }
}
