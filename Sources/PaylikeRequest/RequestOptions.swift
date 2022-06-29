import Foundation

/**
 Describes options for a given request
 */
public struct RequestOptions {
    /**
     Use this initalizer for completely default options
     */
    public init() {}
    /**
     API Version to use
     1 by default
     */
    public let version = 1
    
    /**
     ClientID that appears when the request is made to the backend
     "swift-1" by default
     */
    public let clientId = "swift-1"
    
    /**
     Method of the request
     "GET: by default
     */
    public let method = "GET"
    
    /**
     Query parameters attached to the request
     */
    public let query: [String: String] = [:]
    
    /**
     Encodable data to send to the API
     */
    public let data: Codable? = nil
    
    /**
     Indiciates if the request should be sent out as a form or not
     false by default
     */
    public let form = false
    
    /**
     Fields used in the forms
     */
    public let formFields: [String: String] = [:]
    
    // TODO: TIMEOUT
}
