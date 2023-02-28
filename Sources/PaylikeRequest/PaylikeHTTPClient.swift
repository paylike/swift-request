import Foundation

/**
 * Describing the necessary function for the HTTP client
 */
public protocol HTTPClient {
    
    /**
     * Used for optional logging functionality
     */
    var loggingFn: (Encodable) -> Void { get set }
    
    /**
     * Executes a request based on the endpoint and the optional request options.
     * Using swift concurrency
     */
    @available(swift 5.5)
    func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions
    ) async throws -> PaylikeResponse
    
    /**
     * Executes a request based on the endpoint and the optional request options.
     * Using completion handler solution
     */
    @available(swift, deprecated: 5.5, message: "Use async version if possible")
    func sendRequest(
        to endpoint: URL,
        withOptions options: RequestOptions,
        completion handler: @escaping (Result<PaylikeResponse, Error>) -> Void
    ) -> Void
}

/**
 * Responsible for sending out requests according to the Paylike API requirements
 */
public final class PaylikeHTTPClient : HTTPClient {
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
}
