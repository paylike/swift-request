import Foundation
import Combine

/**
 Describes information for a log line
 */
struct LoggingOp : Codable {
    public var t: String
    public var method: String
    public var url: String
    public var timeout: String
    public var form: String
    public var formFields: [String: String]
    public var headers: [String: String]
}

/**
 Responsible for sending out requests according to the Paylike API requirements
 */
public struct PaylikeRequester {
    /**
     Used for logging, called when the request is constructed
     */
    public var loggingFn: (Encodable) -> Void = { obj in
        print(obj)
    }
    /**
     Use empty init if the default logging is enough for you
     */
    public init() {}
    /**
     Overwrite logging function with your own
     */
    public init(log: @escaping (Encodable) -> Void) {
        self.loggingFn = log
    }
    /**
     Wraps HTTP request execution in a Future
     */
    func executeRequest(request: URLRequest) -> Future<PaylikeResponse, Error> {
        return Future() { promise in
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                if let response = response {
                    promise(.success(PaylikeResponse(urlResponse: response, data: data)))
                    return
                }
                promise(.failure(PaylikeRequestError.UnknownError))
            }.resume()
        }
    }
    /**
     Executes a request based on the endpoint and the optional request options
     */
    public func request(endpoint: String, options: RequestOptions = RequestOptions()) -> Future<PaylikeResponse, Error> {
        var url = URL(string: endpoint)!
        var request = URLRequest(url: url)
        if !options.query.isEmpty {
            let queries = options.query.reduce("") { prev, curr in
                let query = "\(curr.key)=\(curr.value)"
                if prev.isEmpty {
                    return query
                }
                return prev + "&" + query
            }
            url = URL(string: endpoint + "?" + queries)!
            request = URLRequest(url: url)
        }
        if options.form {
            if options.formFields.isEmpty {
                return Future { promise in promise(.failure(PaylikeRequestError.FormNeedsFields)) }
            }
            let formBodyParts = options.formFields.reduce("") { prev, curr in
                let encodedValue = String(describing: curr.value.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
                let keyValuePair = "\(curr.key)=\(encodedValue)"
                if prev.isEmpty {
                    return keyValuePair
                }
                return prev + "&" + keyValuePair
            }
            request.httpMethod = "POST"
            request.httpBody = Data(formBodyParts.data(using: .utf8)!)
            request.addValue(String(request.httpBody!.count), forHTTPHeaderField: "Content-Length")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            loggingFn(LoggingOp(
                t: "request",
                method: "POST",
                url: request.url!.absoluteString,
                timeout: "TODO",
                form: String(options.form),
                formFields: options.formFields,
                headers: request.allHTTPHeaderFields!
            ))
            return executeRequest(request: request)
        }
        request.addValue(String(options.version), forHTTPHeaderField: "Accept-Version")
        request.addValue(options.clientId, forHTTPHeaderField: "X-Client")
        if options.method == "POST" && options.data != nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: options.data!)
            request.httpMethod = "POST"
        }
        loggingFn(LoggingOp(
            t: "request",
            method: request.httpMethod!,
            url: request.url!.absoluteString,
            timeout: "TODO",
            form: String(options.form),
            formFields: options.formFields,
            headers: request.allHTTPHeaderFields!
        ))
        return executeRequest(request: request)
    }
}
