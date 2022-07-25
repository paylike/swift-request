import XCTest
@testable import PaylikeRequest
import Combine
import Swifter

final class PaylikeRequestTests: XCTestCase {
    let requester = PaylikeRequester(log: { item in
        // Don't log in tests
    })
    func testDefaultGetRequest() throws {
        let server = HttpServer()
        server["/bar"] = { request in
            XCTAssertEqual(request.method, "GET")
            XCTAssertEqual(request.headers["accept-version"], "1")
            XCTAssertEqual(request.headers["x-client"], "swift-1")
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
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
    
    func testQuery() throws {
        let server = HttpServer()
        server["/bar"] = { request in
            XCTAssertEqual(request.queryParams.count, 1)
            let param = request.queryParams.first!
            XCTAssertEqual(param.0, "foo")
            XCTAssertEqual(param.1, "bar")
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        var options = RequestOptions()
        options.query = ["foo": "bar"]
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
    
    func testForm() throws {
        let formFields = ["foo": "bar"]
        let server = HttpServer()
        server["/bar"] = { request in
            XCTAssertEqual(request.method, "POST")
            XCTAssertEqual(request.headers["content-type"], "application/x-www-form-urlencoded")
            XCTAssertNotNil(request.headers["content-length"])
            do {
                let body = try XCTUnwrap(String(data: Data(request.body), encoding: .utf8))
                XCTAssertEqual(body, "foo=bar")
            } catch {
                XCTFail("Server should be able to parse body")
            }
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        var options = RequestOptions()
        options.form = true
        options.formFields = formFields
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
    
    func testResponseString() throws {
        let server = HttpServer()
        let text = "some custom text"
        server["/bar"] = { request in
            return .ok(.text(text))
        }
        let expectation = XCTestExpectation(description: "Should be able to parse body")
        try server.start(8080)
        let promise = requester.request(endpoint: "http://localhost:8080/bar", options: RequestOptions())
        var bag: Set<AnyCancellable> = []
        promise.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Should not error out: " + error.localizedDescription)
            default:
                return
            }
        }, receiveValue: { response in
            do {
                let body = try response.getStringBody()
                XCTAssertEqual(body, text)
            } catch {
                XCTFail("Body deserialization should not error out")
            }
            bag.removeAll()
            expectation.fulfill()
        }).store(in: &bag)
        wait(for: [expectation], timeout: 15)
    }
    
    func testTimeout() throws {
        let server = HttpServer()
        server["/bar"] = { request in
            Thread.sleep(forTimeInterval: 5)
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
        let expectation = XCTestExpectation(description: "Timeout should be received")
        var options = RequestOptions()
        options.timeout = 2
        let promise = requester.request(endpoint: "http://localhost:8080/bar", options: options)
        var bag: Set<AnyCancellable> = []
        promise.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual((error as? URLError)?.code, .timedOut)
                    expectation.fulfill()
                default:
                    XCTFail("SHould not be able to do completation here")
                }
            }, receiveValue: { response in
                XCTFail("Should not be able to receive value here")
            }).store(in: &bag)
        wait(for: [expectation], timeout: 15)
        server.stop()
    }
}
