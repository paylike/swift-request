import Foundation

/**
 Describes errors regarding the library
 */
public enum PaylikeHTTPClientError : Error {
    /**
     * Unknown error happened during the request and the response cannot be created
     */
    case UnknownError
    /**
     * Thrown when received query could not be parsed to url
     */
    case QueryToURLParsingError(query: String)
    /**
     * Thrown when the request is supposed to have query but it's empty
     */
    case QueryIsEmpty
    /**
     * Thrown when the request is supposed to be a form but the fields are missing / empty
     */
    case FormIsEmpty
    /**
     * Thrown when the request is supposed to have data but it's empty
     */
    case DataIsEmpty
    /**
     Happens when the response body cannot be deserialized to JSON
     */
    case ResponseCannotBeSerializedToJSON(response: URLResponse)
    /**
     Happens when the response body is empty and / or cannot be represented as a String
     */
    case ResponseCannotBeSerializedToString(response: URLResponse)
}
