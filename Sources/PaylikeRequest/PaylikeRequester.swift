import Foundation
import Combine

public struct PaylikeRequester {
    // TODO: Logging, client
    public init() {}
    
    /**
     Executes a request based on the endpoint and the optional request options
     */
    public func request(endpoint: String, options: RequestOptions = RequestOptions()) async throws -> PaylikeResponse {
        //create the url with NSURL
        let url = URL(string: endpoint)! //change the url
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        return PaylikeResponse(response: response, data: data)
    }
}
