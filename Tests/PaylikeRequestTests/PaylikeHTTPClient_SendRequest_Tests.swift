import Foundation
import Swifter
import XCTest

@testable import PaylikeRequest

final class PaylikeHTTPClient_SendRequest_Tests: XCTestCase {
    
    static var paylikeHTTPClient = PaylikeHTTPClient()
    private static var mockHTTPServer = MockHTTPServer()
    
    public class override func setUp() {
        /*
         * Initializing HTTP client without logging. We do not log in tests
         */
        paylikeHTTPClient.loggingFn = { obj in
            // do nothing
        }
        /*
         * Mock server start
         */
        do {
            try mockHTTPServer.start()
        } catch {
            XCTFail("Server start error: \(error)")
        }
    }
    
    public class override func tearDown() {
        mockHTTPServer.stop()
    }

    
    func testGetRequest() throws {
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testGetRequestPath
        PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(to: URL(string: urlString)!) { result in
            do {
                let response = try result.get()
                let body = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }
    
    func testGetRequest_async() throws {
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testGetRequestPath
        Task {
            let swiftyResponse = try await PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
                to: URL(string: urlString)!
            )
            do {
                let body = try JSONSerialization.jsonObject(with: swiftyResponse.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testPostJSONData() throws {
        let postData = ["message": "bar"]
        let data = try! JSONEncoder().encode(postData)
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testPostJSONDataPath
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
            to: URL(string: urlString)!,
            withOptions: RequestOptions(withData: data)
        ) { result in
            do {
                let response = try result.get()
                let body = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testPostJSONData_async() throws {
        let postData = ["message": "bar"]
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testPostJSONDataPath
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        Task {
            let swiftyResponse = try await PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
                to: URL(string: urlString)!,
                withOptions: RequestOptions(withData: JSONEncoder().encode(postData))
            )
            do {
                let body = try JSONSerialization.jsonObject(with: swiftyResponse.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testQuery() throws {
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testQueryPath
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        var options = RequestOptions()
        options.query = ["foo": "bar"]
        PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
            to: URL(string: urlString)!,
            withOptions: options
        ) { result in
            do {
                let response = try result.get()
                let body = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testQuery_async() throws {
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testQueryPath
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        Task {
            var options = RequestOptions()
            options.query = ["foo": "bar"]
            let swiftyResponse = try await PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
                to: URL(string: urlString)!,
                withOptions: options
            )
            do {
                let body = try JSONSerialization.jsonObject(with: swiftyResponse.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testForm() throws {
        let formFields = ["foo": "bar"]
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testFormPath
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        let options = RequestOptions(withFormFields: formFields)
        PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
            to: URL(string: urlString)!,
            withOptions: options
        ) { result in
            do {
                let response = try result.get()
                let body = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testForm_async() throws {
        let formFields = ["foo": "bar"]
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testFormPath
        let valueExpectation = XCTestExpectation(description: "Value should be received")
        let options = RequestOptions(withFormFields: formFields)
        Task {
            let swiftyResponse = try await PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
                to: URL(string: urlString)!,
                withOptions: options
            )
            do {
                let body = try JSONSerialization.jsonObject(with: swiftyResponse.data!, options: .mutableContainers) as? [String: Any]
                XCTAssertNotNil(body)
                let message = body!["message"]! as? String
                XCTAssertEqual(message, "foo")
            } catch {
                XCTFail("\(error)")
            }
            valueExpectation.fulfill()
        }
        wait(for: [valueExpectation], timeout: 2)
    }

    func testResponseString() throws {
        let text = "some custom text"
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testResponseStringPath
        let expectation = XCTestExpectation(description: "Should be able to parse body")
        PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
            to: URL(string: urlString)!
        ) { result in
            do {
                let response = try result.get()
                let body = String(data: response.data!, encoding: .utf8)
                XCTAssertEqual(body, text)
            } catch {
                XCTFail("Body deserialization should not error out")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testResponseString_async() throws {
        let text = "some custom text"
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testResponseStringPath
        let expectation = XCTestExpectation(description: "Should be able to parse body")
        Task {
            do {
                let swiftyResponse = try await PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
                    to: URL(string: urlString)!
                )
                let body = String(data: swiftyResponse.data!, encoding: .utf8)
                XCTAssertEqual(body, text)
            } catch {
                XCTFail("Body deserialization should not error out")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testTimeout() throws {
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testTimeoutPath
        let expectation = XCTestExpectation(description: "Timeout should be received")
        var options = RequestOptions()
        options.timeoutInterval = 2
        PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
            to: URL(string: urlString)!,
            withOptions: options
        ) { result in
            do {
                let _ = try result.get()
                XCTFail("Should not be able to do completation here")
            } catch {
                XCTAssertEqual((error as? URLError)?.code, .timedOut)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testTimeout_async() throws {
        let urlString = Self.mockHTTPServer.schemeAndHostAndPort + Self.mockHTTPServer.testTimeoutPath
        let expectation = XCTestExpectation(description: "Timeout should be received")
        Task {
            var options = RequestOptions()
            options.timeoutInterval = 2

            do {
                _ = try await PaylikeHTTPClient_SendRequest_Tests.paylikeHTTPClient.sendRequest(
                    to: URL(string: urlString)!,
                    withOptions: options
                )
                XCTFail("Should not be able to do completation here")
            } catch {
                XCTAssertEqual((error as? URLError)?.code, .timedOut)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
