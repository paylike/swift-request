import Foundation

/**
 * Responsible for sending out requests according to the Paylike API requirements
 */
@available(iOS 13.0, macOS 10.15, *)
public struct PaylikeHTTPClient {
    /**
     * Used for logging, called when the request is constructed
     */
    public var loggingFn: (Encodable) -> Void = { obj in
        print("HTTP Client logger:", terminator: " ")
        debugPrint(obj)
    }
    
    /**
     * Executes a request based on the endpoint and the optional request options
     */
    @available(iOS 13.0, macOS 10.15, *)
    public func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions = RequestOptions()
    ) async throws -> PaylikeResponse {
        
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
            if #available(iOS 16.0, macOS 13.0, *) {
                query.forEach { key, value in
                    url.append(queryItems: [URLQueryItem(name: key, value: value)])
                }
            } else {
                let queryString = query.reduce("") { prev, curr in
                    let query = "\(curr.key)=\(curr.value)"
                    if prev.isEmpty {
                        return query
                    }
                    return prev + "&" + query
                }
                guard let newURL = URL(string: "?" + String(queryString), relativeTo: url) else {
                    throw PaylikeHTTPClientError.QueryToURLParsingError(query: queryString)
                }
                url = newURL
            }
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
        
        /**
         * Try and execute async request and rethrow error
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
}
