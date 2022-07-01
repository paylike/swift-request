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
     Unknown error happened during the request and the response cannot be created
     */
    case UnknownError
}
