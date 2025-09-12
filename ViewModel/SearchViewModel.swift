//
//  SearchViewModel.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.
//
import Foundation


@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var books: [BookDoc] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var currentPage = 1
    @Published var hasMore = true
    
    private let service = OpenLibraryService()
    
    //MARK: Search
    func search(reset: Bool = true) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        if reset {
            currentPage = 1
            hasMore = true
            isLoading = true
        } else {
            isLoadingMore = true
        }

        defer {
            isLoading = false
            isLoadingMore = false
        }

        do {
            let result = try await service.searchBooks(title: trimmedQuery, page: currentPage)

            if reset && result.docs.isEmpty {
                print("No new results, keeping existing books.")
                return
            }

            if reset {
                books = result.docs
            } else {
                books.append(contentsOf: result.docs)
            }

            hasMore = !result.docs.isEmpty
            if hasMore { currentPage += 1 }

        } catch {
            print("API Error: \(error)")
            if reset {
                print("Search failed, keeping existing books.")
            }
        }
    }

    //MARK: Load More
    func loadMoreIfNeeded(currentBook: BookDoc) async {
        guard hasMore, !isLoading, !isLoadingMore else { return }
        
        if let last = books.last, last.id == currentBook.id {
            await search(reset: false)
        }
    }
}


