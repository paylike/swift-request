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
            return [:]
        }
        return json
    }
}
