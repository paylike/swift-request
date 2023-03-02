import Foundation

extension PaylikeHTTPClient {
    
    /**
     * Executes a request based on the endpoint and the optional request options
     */
    public func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions = RequestOptions(),
        completion handler: @escaping (Result<PaylikeResponse, Error>) -> Void
    ) -> Void {
        do {
            /*
             * Get necessary request
             */
            let request = try buildRequest(to: endpoint, withOptions: options)
            /*
             * Logging the request to be made
             */
            loggingFn(LoggingFormat(
                t: "Created request:",
                url: request.url!.absoluteString,
                method: request.httpMethod!,
                timeout: String(request.timeoutInterval),
                formFields: options.formFields,
                headers: request.allHTTPHeaderFields!
            ))
            /*
             * Executes request and returns `PaylikeResponse(data:urlResponse)` or `error` or `PaylikeHTTPClientError.NoHTTPResponse(error:data:)`
             */
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    handler(.failure(error))
                    return
                }
                guard let response = response else {
                    handler(.failure(HTTPClientError.NoHTTPResponse(error, data)))
                    return
                }
                handler(.success(PaylikeResponse(data: data, urlResponse: response)))
            }.resume()
        } catch {
            handler(.failure(error))
        }
    }
    
    /**
     * `sendRequest(to:withOption:completion)` wrapped in `async` syntax
     */
    @available(iOS 13.0, macOS 10.15, *)
    public func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions = RequestOptions()
    ) async throws -> PaylikeResponse {
        return try await withCheckedThrowingContinuation { continuation in
            sendRequest(to: endpoint, withOptions: options) { response in
                continuation.resume(with: response)
            }
        }
    }
    
    /**
     * Builds `URLRequest` based on the parameters
     */
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
            var queryItems: [URLQueryItem] = []
            query.forEach { key, value in
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw HTTPClientError.InvalidURL(url)
            }
            urlComponents.queryItems = queryItems
            guard let newUrl = urlComponents.url else {
                throw HTTPClientError.InvalidURL(url)
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
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}
