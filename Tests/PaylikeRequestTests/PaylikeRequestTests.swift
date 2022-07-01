import XCTest
@testable import PaylikeRequest
import Combine
import Swifter

public enum TestErrors : Error {
    case Timeout
}

final class PaylikeRequestTests: XCTestCase {
    func testExecution() throws {
        let server = HttpServer()
        server["/bar"] = { request in
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
        let requester = PaylikeRequester()
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        let promise = requester.request(endpoint: "http://localhost:8080/bar")
        var bag: Set<AnyCancellable> = []
        promise.sink(
            receiveCompletion: { _ in
            }, receiveValue: { response in
                do {
                    let body = try response.getJSONBody()
                    XCTAssertNotNil(body)
                    let message = body["message"]! as? String
                    XCTAssertEqual(message, "foo")
                } catch {
                    XCTFail("\(error)")
                }
                valueExpectation.fulfill()
            }).store(in: &bag)
        wait(for: [valueExpectation], timeout: 30)
        server.stop()
    }
}
