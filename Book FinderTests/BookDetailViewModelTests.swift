//
//  BookDetailViewModelTests.swift
//  Book FinderTests
//
//  Created by sci on 12/09/25.
//

import Testing
@testable import BookFinder

final class MockBookRepository: BookRepositoryProtocol {
    func save(_ book: BookFinder.BookDoc) {
    }
    
    func delete(_ book: BookFinder.BookDoc) {
    }
    
    func fetchAll() -> [BookFinder.BookDoc] {
        return []
    }
    
    func isFavorite(_ book: BookFinder.BookDoc) -> Bool {
        return isFavoriteResult
    }
    
    var isFavoriteResult = false
    var savedBook: BookDoc?
    var deletedKey: String?

    func isFavorite(workKey: String) -> Bool {
        return isFavoriteResult
    }

    func saveFavorite(book: BookDoc, detailsJSON: String?) -> Bool {
        self.savedBook = book
        return true
    }

    func deleteFavorite(workKey: String) -> Bool {
        self.deletedKey = workKey
        return true
    }
}

@MainActor
struct BookDetailViewModelTests {
    var mockRepository = MockBookRepository()
    var sut: BookDetailViewModel

    init() {
        self.sut = BookDetailViewModel(workKey: "work-key-1", repository: mockRepository)
    }

    @Test("Test that initialization sets isFavorite correctly")
    func test_initialization_setsIsFavoriteCorrectly() {
        mockRepository.isFavoriteResult = true
        let viewModel = BookDetailViewModel(workKey: "work-key-1", repository: mockRepository)
        
        #expect(viewModel.isFavorite == true)
    }

    @Test("Test that toggling favorite adds the book")
    func test_toggleFavorite_addsBook_whenNotFavorite() async {
        mockRepository.isFavoriteResult = false
        sut.isFavorite = false
        
        await sut.toggleFavorite()

        await Task.yield()

        await #expect(sut.isFavorite == true)
        #expect(mockRepository.savedBook != nil)
        #expect(mockRepository.deletedKey == nil)
    }

    @Test("Test that toggling favorite deletes the book")
    func test_toggleFavorite_deletesBook_whenIsFavorite() async {
        mockRepository.isFavoriteResult = true
        sut.isFavorite = true 
        
        await sut.toggleFavorite()

        await Task.yield()

        await #expect(sut.isFavorite == false)
        #expect(mockRepository.savedBook == nil)
        #expect(mockRepository.deletedKey == "work-key-1")
    }
}
