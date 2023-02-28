import Foundation

/**
 Describes errors regarding the library
 */
public enum HTTPClientError : Error {
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
}
