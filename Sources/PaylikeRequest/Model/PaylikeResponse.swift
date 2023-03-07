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
    
    /// @TODO: put parsing to higher level http client?
    /**
     * Returns JSON body if possible
     */
    public func getJSONBody() throws -> [String: Any] {
        if data == nil {
            throw HTTPClientError.ResponseCannotBeSerializedToJSON(urlResponse)
        }
        guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] else {
            throw HTTPClientError.ResponseCannotBeSerializedToJSON(urlResponse)
        }
        return json
    }
    /**
     * Returns body as string if possible
     */
    public func getStringBody() throws -> String {
        if data == nil {
            throw HTTPClientError.ResponseCannotBeSerializedToString(urlResponse)
        }
        guard let body = String(data: data!, encoding: String.Encoding.utf8) else {
            throw HTTPClientError.ResponseCannotBeSerializedToString(urlResponse)
        }
        return body
    }
}
