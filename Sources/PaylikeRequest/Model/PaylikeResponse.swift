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
     * The underlying response information
     */
    public let urlResponse: URLResponse
    
    /**
     * Returns JSON body if possible
     */
    public func getJSONBody() throws -> [String: Any] {
        if data == nil {
            throw PaylikeHTTPClientError.ResponseCannotBeSerializedToJSON(response: urlResponse)
        }
        guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] else {
            throw PaylikeHTTPClientError.ResponseCannotBeSerializedToJSON(response: urlResponse)
        }
        return json
    }
    /**
     * Returns body as string if possible
     */
    public func getStringBody() throws -> String {
        if data == nil {
            throw PaylikeHTTPClientError.ResponseCannotBeSerializedToString(response: urlResponse)
        }
        guard let body = String(data: data!, encoding: String.Encoding.utf8) else {
            throw PaylikeHTTPClientError.ResponseCannotBeSerializedToString(response: urlResponse)
        }
        return body
    }
}
