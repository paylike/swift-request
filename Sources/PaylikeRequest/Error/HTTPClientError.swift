import Foundation

/**
 * Describes errors regarding the HTTP Client and it's close components
 */
public enum HTTPClientError : Error, LocalizedError {
    /**
     * Unknown error happened during the request and the response cannot be created
     */
    case UnknownError
    /**
     * Thrown when the URL is invalid
     */
    case InvalidURL(_ url: URL)
    /**
     * Thrown when received response is not `HTTPURLResponse`
     */
    case NotHTTPURLResponse(_ response: URLResponse)
    /**
     * Thrown when `dataTask` does not give response
     */
    case NoHTTPResponse(_ error: Error?, _ data: Data?)
    /**
     Happens when the response body cannot be deserialized to JSON
     */
    case ResponseCannotBeSerializedToJSON(_ response: URLResponse)
    /**
     Happens when the response body is empty and / or cannot be represented as a String
     */
    case ResponseCannotBeSerializedToString(_ response: URLResponse)
    
    /**
     * Localized text of the error messages
     */
    public var errorDescription: String? {
        switch self {
            case .UnknownError:
                return "UnknownError"
            case .InvalidURL(url: let url):
                return "Invalid URL: \(url.absoluteString)"
            case .NotHTTPURLResponse(_):
                return "Not HTTP URL response"
            case .NoHTTPResponse(_, _):
                return "Not HTTP Resposne"
            case .ResponseCannotBeSerializedToJSON(_):
                return "Response cannot be serialized to JSON"
            case .ResponseCannotBeSerializedToString(_):
                return "Response cannto be serialized to String"
        }
    }
}
