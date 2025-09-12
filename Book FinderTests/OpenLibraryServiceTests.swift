//
//  OpenLibraryServiceTests.swift
//  BookFinderTests
//
//  Created by sci on 12/09/25.
//

import XCTest
@testable import BookFinder

final class URLSessionMock: URLSession, @unchecked Sendable {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        
        let data = self.data
        let response = self.response
        let error = self.error
        
        return DummyURLSessionDataTask {
            completionHandler(data, response, error)
        }
    }
}

private class DummyURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    let closure: () -> Void
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    override func resume() {
        closure()
    }
}

final class OpenLibraryServiceTests: XCTestCase {
    var service: OpenLibraryService!
    var mockSession: URLSessionMock!
    
    override func setUp() {
        super.setUp()
        mockSession = URLSessionMock()
        service = OpenLibraryService(session: mockSession)
    }
    
    override func tearDown() {
        service = nil
        mockSession = nil
        super.tearDown()
    }
    
    func test_fetchWorkDetails_fetchesAndDecodesDataCorrectly() async throws {
        let jsonString = """
        {
            "title": "The God of Small Things",
            "key": "/works/OL15804W",
            "subjects": ["Historical Fiction", "Humor""]
        }
        """
        mockSession.data = jsonString.data(using: .utf8)
        mockSession.response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let workDetails = try await service.fetchWorkDetails(workKey: "OL45804W")
        
        XCTAssertEqual(workDetails.title, "The God of Small Things")
        XCTAssertEqual(workDetails.subjects, ["Historical Fiction", "Humor"])
    }
    
    func test_fetchWorkDetails_throwsErrorForInvalidResponse() async {
        mockSession.data = nil
        mockSession.response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        
        do {
            _ = try await service.fetchWorkDetails(workKey: "invalid-key")
            XCTFail("Fetching with invalid response should throw an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
