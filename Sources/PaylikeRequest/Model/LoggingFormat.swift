/**
 * Describes information for a log line
 */
internal struct LoggingFormat : Encodable {
    public var t: String
    public var url: String
    public var method: String
    public var timeout: String
    public var formFields: [String: String]?
    public var headers: [String: String]
}
