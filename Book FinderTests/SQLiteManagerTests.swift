//
//  SQLiteManagerTests.swift
//  BookFinderTests
//
//  Created by sci on 12/09/25.
//

import XCTest
@testable import BookFinder

final class SQLiteManagerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        SQLiteManager.shared.dbPath = ":memory:"
        let _ = SQLiteManager.shared.createTable()
    }

    override func tearDownWithError() throws {
        SQLiteManager.shared.closeDatabase()
        SQLiteManager.shared.dbPath = "favorites.sqlite"
        try super.tearDownWithError()
    }

    func test_saveFavorite_addsBookToDatabase() {
        let book = BookDoc(title: "The Great Gatsby", author_name: ["F. Scott Fitzgerald"], cover_i: 123, key: "work-key-1", first_publish_year: 1925, isbn: ["12345"])
        let saveStatus = SQLiteManager.shared.saveFavorite(book: book, detailsJSON: nil)
        
        XCTAssertTrue(saveStatus, "Save operation should be successful")
        
        let isFavorite = SQLiteManager.shared.isFavorite(workKey: "work-key-1")
        XCTAssertTrue(isFavorite, "The saved book should be marked as favorite")
    }

    func test_deleteFavorite_removesBookFromDatabase() {
        let book = BookDoc(title: "1984", author_name: ["George Orwell"], cover_i: 456, key: "work-key-2", first_publish_year: 1949, isbn: ["67890"])
        _ = SQLiteManager.shared.saveFavorite(book: book, detailsJSON: nil)
        
        let deleteStatus = SQLiteManager.shared.deleteFavorite(workKey: "work-key-2")
        
        XCTAssertTrue(deleteStatus, "Delete operation should be successful")
        
        let isFavorite = SQLiteManager.shared.isFavorite(workKey: "work-key-2")
        XCTAssertFalse(isFavorite, "The book should no longer be in favorites")
    }

    func test_isFavorite_returnsFalseWhenDatabaseIsEmpty() {
        let isFavorite = SQLiteManager.shared.isFavorite(workKey: "work-key-3")
        XCTAssertFalse(isFavorite, "A non-existent book should not be a favorite")
    }
}
