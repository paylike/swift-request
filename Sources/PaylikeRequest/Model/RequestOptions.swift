import Foundation

/**
 * Encapsulating and necessary fields to create a sufficient request towards the Paylike backend services.
 */
public struct RequestOptions {
    /**
     * Query parameters attached to the URL
     */
    public var query: [String: String]?
    /**
     * Timeout interval in the request in seconds. Default is 60 based on URLRequest default.
     */
    public var timeoutInterval: Double?
    /**
     * API Version to use
     */
    public var version = 1
    /**
     * ClientID that appears when the request is made to the backend
     */
    public var clientId = "swift-1"
    /**
     * Method of the request, Paylike APIs require "GET" or "POST"
     */
    public let httpMethod: String
    /**
     * Encodable data to send to the API
     */
    public let data: Data?
    /**
     * Fields used in the forms
     */
    public let formFields: [String: String]?
    
    /**
     * Initialization with method = "GET"
     */
    public init() {
        self.httpMethod = "GET"
        self.data = nil
        self.formFields = nil
    }
    /**
     * Initialization with method = "POST"
     */
    public init(withData data: Data) {
        self.httpMethod = "POST"
        self.data = data
        self.formFields = nil
    }
    /**
     * Initialization with method = "POST"
     */
    public init(withFormFields formFields: [String: String]) {
        self.httpMethod = "POST"
        self.data = nil
        self.formFields = formFields
    }
}
