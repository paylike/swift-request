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
        //create the url with NSURL
        let url = URL(string: endpoint)! //change the url
        let request = URLRequest(url: url)
        return exceuteRequest(request: request)
    }
}
