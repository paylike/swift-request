import Foundation
import Swifter
import XCTest

@testable import PaylikeRequest

internal class MockHTTPServer {
    
    public let schemeAndHostAndPort = "http://localhost:8080"
    public let port = 8080
    public let testGetRequestPath = "/bar0"
    public let testPostJSONDataPath = "/bar2"
    public let testQueryPath = "/bar3"
    public let testFormPath = "/bar4"
    public let testResponseStringPath = "/bar5"
    public let testTimeoutPath = "/bar6"
    

    private let server: HttpServer
    
    internal init(server: HttpServer = HttpServer()) {
        self.server = server
        
        server[testGetRequestPath] = { request in
            XCTAssertEqual(request.method, "GET")
            XCTAssertEqual(request.headers["accept-version"], "1")
            XCTAssertEqual(request.headers["x-client"], "swift-1")
            return .ok(.json(["message": "foo"]))
        }
        server[testPostJSONDataPath] = { request in
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
        server[testQueryPath] = { request in
            XCTAssertEqual(request.queryParams.count, 1)
            let param = request.queryParams[0]
            XCTAssertEqual(param.0, "foo")
            XCTAssertEqual(param.1, "bar")
            return .ok(.json(["message": "foo"]))
        }
        server[testFormPath] = { request in
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
        server[testResponseStringPath] = { request in
            let text = "some custom text"

            return .ok(.text(text))
        }
        server[testTimeoutPath] = { request in
            Thread.sleep(forTimeInterval: 5)
            return .ok(.json(["message": "foo"]))
        }

    }
    
    internal func start() throws {
        try server.start(in_port_t(port))
    }
    
    internal func stop() {
        server.stop()
    }
}
