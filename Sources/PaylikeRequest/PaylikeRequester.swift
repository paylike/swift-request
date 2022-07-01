import Foundation
import Combine

public struct PaylikeRequester {
    // TODO: Logging, client
    public init() {}
    func exceuteRequest(request: URLRequest) -> Future<PaylikeResponse, Error> {
        return Future() { promise in
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                if let response = response {
                    promise(.success(PaylikeResponse(response: response, data: data)))
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
        request.addValue(String(options.version), forHTTPHeaderField: "Accept-Version")
        request.addValue(options.clientId, forHTTPHeaderField: "X-Client")
        if options.method == "POST" && options.data != nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: options.data!)
            request.httpMethod = "POST"
        }
        return exceuteRequest(request: request)
    }
}
