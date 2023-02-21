import Foundation
import Swifter
import XCTest

@testable import PaylikeRequest

final class PaylikeHTTPClientTests: XCTestCase {
    
    var paylikeHTTPClient = PaylikeHTTPClient()
    
    convenience override init() {
        self.init()

        /**
         * Initializing HTTP client without logging. We do not log in tests
         */
        paylikeHTTPClient.loggingFn = { obj in
            // do nothing
        }
    }
    
    func testDefaultGetRequest() throws {
        let swiftyServer = HttpServer()
        swiftyServer["/bar"] = { request in
            XCTAssertEqual(request.method, "GET")
            XCTAssertEqual(request.headers["accept-version"], "1")
            XCTAssertEqual(request.headers["x-client"], "swift-1")
            return .ok(.json(["message": "foo"]))
        }
        try swiftyServer.start(8080)
        
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        
        Task {
            let swiftyResponse = try await paylikeHTTPClient.sendRequest(
                to: URL(string: "http://localhost:8080/bar")!
            )
            valueExpectation.fulfill()
            
            do {
                let body = try swiftyResponse.getJSONBody()
                XCTAssertNotNil(body)
                let message = body["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            
            swiftyServer.stop()
        }
        wait(for: [valueExpectation], timeout: 2)
        Thread.sleep(forTimeInterval: 2)
    }
    
    func testPostJSONData() throws {
        
        let postData = ["message": "bar"]
        
        let swiftyServer = HttpServer()
        swiftyServer["/bar"] = { request in
            XCTAssertEqual(request.method, "POST")
            XCTAssertEqual(request.headers["accept-version"], "1")
            XCTAssertEqual(request.headers["x-client"], "swift-1")
            XCTAssertEqual(request.headers["content-type"], "application/json")
            do {
                let body = Data(request.body)
                let json: Dictionary<String, String> = try JSONDecoder().decode(Dictionary<String, String>.self, from: body)
                XCTAssertEqual(json["message"], "bar")
            } catch {
                XCTFail("Should be able to parse JSON body in server handler")
            }
            return .ok(.json(["message": "foo"]))
        }
        try swiftyServer.start(8080)
        
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        
        Task {
            let swiftyResponse = try await paylikeHTTPClient.sendRequest(
                to: URL(string: "http://localhost:8080/bar")!,
                withOptions: RequestOptions(withData: JSONEncoder().encode(postData))
            )
            valueExpectation.fulfill()
            
            do {
                let body = try swiftyResponse.getJSONBody()
                XCTAssertNotNil(body)
                let message = body["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            
            swiftyServer.stop()
        }
        wait(for: [valueExpectation], timeout: 2)
        Thread.sleep(forTimeInterval: 2)
    }
    
    func testQuery() throws {
        let swiftyServer = HttpServer()
        swiftyServer["/bar"] = { request in
            XCTAssertEqual(request.queryParams.count, 1)
            debugPrint(request.queryParams)
            let param = request.queryParams[0]
            XCTAssertEqual(param.0, "foo")
            XCTAssertEqual(param.1, "bar")
            return .ok(.json(["message": "foo"]))
        }
        try swiftyServer.start(8080)
        
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        
        Task {
            
            var options = RequestOptions()
            options.query = ["foo": "bar"]
            
            let swiftyResponse = try await paylikeHTTPClient.sendRequest(
                to: URL(string: "http://localhost:8080/bar")!,
                withOptions: options
            )
            valueExpectation.fulfill()
            
            do {
                let body = try swiftyResponse.getJSONBody()
                XCTAssertNotNil(body)
                let message = body["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            swiftyServer.stop()
        }
        wait(for: [valueExpectation], timeout: 2)
        Thread.sleep(forTimeInterval: 2)
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
        
        let options = RequestOptions(withFormFields: formFields)
        
        Task {
            let swiftyResponse = try await paylikeHTTPClient.sendRequest(
                to: URL(string: "http://localhost:8080/bar")!,
                withOptions: options
            )
            valueExpectation.fulfill()
            
            do {
                let body = try swiftyResponse.getJSONBody()
                XCTAssertNotNil(body)
                let message = body["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            server.stop()
        }
        wait(for: [valueExpectation], timeout: 2)
        Thread.sleep(forTimeInterval: 2)
    }
    
    func testResponseString() throws {
        
        let text = "some custom text"
        
        let swiftyServer = HttpServer()
        swiftyServer["/bar"] = { request in
            return .ok(.text(text))
        }
        try swiftyServer.start(8080)
        
        let expectation = XCTestExpectation(description: "Should be able to parse body")
        
        Task {
            let swiftyResponse = try await paylikeHTTPClient.sendRequest(
                to: URL(string: "http://localhost:8080/bar")!
            )
            do {
                let body = try swiftyResponse.getStringBody()
                XCTAssertEqual(body, text)
                expectation.fulfill()
            } catch {
                XCTFail("Body deserialization should not error out")
            }
            swiftyServer.stop()
        }
        wait(for: [expectation], timeout: 2)
        Thread.sleep(forTimeInterval: 2)
    }
    
    func testTimeout() throws {
        let server = HttpServer()
        server["/bar"] = { request in
            Thread.sleep(forTimeInterval: 5)
            return .ok(.json(["message": "foo"]))
        }
        try server.start(8080)
        
        let expectation = XCTestExpectation(description: "Timeout should be received")
        
        Task {
            var options = RequestOptions()
            options.timeoutInterval = 2
            
            do {
                _ = try await paylikeHTTPClient.sendRequest(
                    to: URL(string: "http://localhost:8080/bar")!,
                    withOptions: options
                )
                XCTFail("Should not be able to do completation here")
            } catch {
                XCTAssertEqual((error as? URLError)?.code, .timedOut)
                expectation.fulfill()
            }
            server.stop()
        }
        wait(for: [expectation], timeout: 5)
    }
}
