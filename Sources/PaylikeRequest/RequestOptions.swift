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
    public var version = 1
    
    /**
     ClientID that appears when the request is made to the backend
     "swift-1" by default
     */
    public var clientId = "swift-1"
    
    /**
     Method of the request
     "GET" by default
     */
    public var method = "GET"
    
    /**
     Query parameters attached to the request
     */
    public var query: [String: String] = [:]
    
    /**
     Encodable data to send to the API
     */
    public var data: Codable? = nil
    
    /**
     Indiciates if the request should be sent out as a form or not
     false by default
     */
    public var form = false
    
    /**
     Fields used in the forms
     */
    public var formFields: [String: String] = [:]
    
    /**
     Timeout interval in the request in seconds
     */
    public var timeout: Double = 60
}
