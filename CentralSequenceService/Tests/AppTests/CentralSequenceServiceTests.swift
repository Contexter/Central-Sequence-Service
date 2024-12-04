import XCTest
import XCTVapor
@testable import App

final class CentralSequenceServiceTests: XCTestCase {
    
    var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testValidSequenceGeneration() throws {
        let requestBody = """
        {
            "elementType": "character",
            "elementId": 1,
            "comment": "Testing sequence generation for character"
        }
        """
        try app.test(.POST, "/sequence", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody, as: .json)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains("Sequence generation endpoint reached"))
        })
    }
    
    func testInvalidPath() throws {
        let requestBody = """
        {
            "elementType": "character",
            "elementId": 1,
            "comment": "Testing invalid path"
        }
        """
        try app.test(.POST, "/invalid-path", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody, as: .json)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("Path /invalid-path is not defined in the OpenAPI specification."))
        })
    }
    
    func testUnsupportedMethod() throws {
        try app.test(.GET, "/sequence", afterResponse: { res in
            XCTAssertEqual(res.status, .methodNotAllowed)
            XCTAssertTrue(res.body.string.contains("HTTP method GET is not allowed for the requested path."))
        })
    }
    
    func testMissingContentType() throws {
        let requestBody = """
        {
            "elementType": "character",
            "elementId": 1,
            "comment": "Missing Content-Type header"
        }
        """
        try app.test(.POST, "/sequence", beforeRequest: { req in
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("Missing Content-Type header"))
        })
    }
    
    func testUnsupportedContentType() throws {
        let requestBody = """
        <xml>
            <elementType>character</elementType>
            <elementId>1</elementId>
            <comment>Unsupported Content-Type</comment>
        </xml>
        """
        try app.test(.POST, "/sequence", beforeRequest: { req in
            req.headers.contentType = .xml
            req.body = ByteBuffer(string: requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unsupportedMediaType)
            XCTAssertTrue(res.body.string.contains("Unsupported Content-Type"))
        })
    }
}
