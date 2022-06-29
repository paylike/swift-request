import XCTest
@testable import PaylikeRequest

final class PaylikeRequestTests: XCTestCase {
    func testExecution() async throws {
        let requester = PaylikeRequester()
        let response = try await requester.request(endpoint: "https://random-data-api.com/api/users/random_user")
        let body = try response.getJSONBody()
        XCTAssertNotNil(body)
    }
}
