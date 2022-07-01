import XCTest
@testable import PaylikeRequest
import Combine
import Swifter

final class PaylikeRequestTests: XCTestCase {
    func testDefaultGetRequest() throws {
        let server = HttpServer()
        server["/bar"] = { request in
            XCTAssertEqual(request.method, "GET")
            XCTAssertEqual(request.headers["accept-version"], "1")
            XCTAssertEqual(request.headers["x-client"], "swift-1")
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
    
    func testPostJSONData() throws {
        let server = HttpServer()
        let postData = ["message": "bar"]
        server["/bar"] = { request in
            XCTAssertEqual(request.method, "POST")
            XCTAssertEqual(request.headers["accept-version"], "1")
            XCTAssertEqual(request.headers["x-client"], "swift-1")
            XCTAssertEqual(request.headers["content-type"], "application/json")
            do {
                let body = Data(request.body)
                let json = try JSONSerialization.jsonObject(with: body, options: .mutableContainers) as? [String: Any]
                XCTAssertEqual(json!["message"]! as? String, "bar")
            } catch {
                XCTFail("Should be able to parse JSON body in server handler")
            }
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
        let requester = PaylikeRequester()
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        var options = RequestOptions()
        options.method = "POST"
        options.data = postData
        let promise = requester.request(endpoint: "http://localhost:8080/bar", options: options)
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
