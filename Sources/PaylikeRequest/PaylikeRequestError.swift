import Foundation

/**
 Describes errors regarding the library
 */
public enum PaylikeRequestError : Error {
    /**
     Happens when the response body cannot be deserialized to JSON
     */
    case ResponseCannotBeSerializedToJSON(response: URLResponse)
    /**
     Happens when the response body is empty and / or cannot be represented as a String
     */
    case ResponseCannotBeSerializedToString(response: URLResponse)
    /**
     Thrown when the request is supposed to be a form
     but the fields are missing / empty
     */
    case FormNeedsFields
    /**
     Unknown error happened during the request and the response cannot be created
     */
    case UnknownError
}
