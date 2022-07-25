import Foundation
import Combine

/**
 Holds information about a response received from the Paylike API
 */
public struct PaylikeResponse {
    /**
     The underlying response information
     */
    public let urlResponse: URLResponse
    /**
     Data returned in the body
     */
    public let data: Data?
    /**
     Returns JSON body if possible
     */
    public func getJSONBody() throws -> [String: Any] {
        if data == nil {
            throw PaylikeRequestError.ResponseCannotBeSerializedToJSON(response: urlResponse)
        }
        guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] else {
            throw PaylikeRequestError.ResponseCannotBeSerializedToJSON(response: urlResponse)
        }
        return json
    }
    /**
     Returns body as string if possible
     */
    public func getStringBody() throws -> String {
        if data == nil {
            throw PaylikeRequestError.ResponseCannotBeSerializedToString(response: urlResponse)
        }
        guard let body = String(data: data!, encoding: String.Encoding.utf8) else {
            throw PaylikeRequestError.ResponseCannotBeSerializedToString(response: urlResponse)
        }
        return body
    }
}
