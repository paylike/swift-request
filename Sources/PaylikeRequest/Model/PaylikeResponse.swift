import Foundation

/**
 * Holds information about a response received from the Paylike API
 */
public struct PaylikeResponse {
    /**
     * Data returned in the body
     */
    public let data: Data?
    /**
     * Underlying response information
     */
    public let urlResponse: URLResponse
    
    public init(data: Data?, urlResponse: URLResponse) {
        self.data = data
        self.urlResponse = urlResponse
    }
}
