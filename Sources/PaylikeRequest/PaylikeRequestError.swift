import Foundation

/**
 Describes errors regarding the library
 */
public enum PaylikeRequestError : Error {
    /**
     Happens when the input is considered an unsafe integer
     */
    case ResponseCannotBeSerializedToJSON(response: URLResponse)
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
