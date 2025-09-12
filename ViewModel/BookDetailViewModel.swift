//
//  BookDetailViewModel.swift
//  Book Finder
//
//  Created by Admin on 12/09/25.
//

import Foundation

@MainActor
final class BookDetailViewModel: ObservableObject {
    @Published var details: WorkDetails?
    @Published var isLoading = false
    @Published var isFavorite = false

    private let workKey: String
    private let service = OpenLibraryService()
    @Published var initialBook: BookDoc?  


    init(workKey: String, book: BookDoc? = nil) {
        self.workKey = workKey
        self.initialBook = book
        self.isFavorite = SQLiteManager.shared.isFavorite(workKey: workKey)
    }

    func fetch() async {
        isLoading = true
        do {
            let fetched = try await service.fetchWorkDetails(workKey: workKey)
            self.details = fetched
            
            
            
        } catch {
            print("Detail fetch error:", error)
        }
        isLoading = false
    }

    func toggleFavorite() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            let key = self.workKey
            if SQLiteManager.shared.isFavorite(workKey: key) {
                let ok = SQLiteManager.shared.deleteFavorite(workKey: key)
                await MainActor.run { self.isFavorite = !ok ? self.isFavorite : false }
            } else {
                var bookToSave: BookDoc
                if let b = await self.initialBook {
                    bookToSave = b
                } else {
                    let title = await self.details?.title
                    let authors = await self.details?.subjects
                    bookToSave = BookDoc(title: title, author_name: nil, cover_i: nil, key: key, first_publish_year: nil, isbn: nil)
                }
                
                var detailsJSON: String? = nil
                if let d = await self.details, let data = try? JSONEncoder().encode(d) {
                    detailsJSON = String(data: data, encoding: .utf8)
                }
                let ok = SQLiteManager.shared.saveFavorite(book: bookToSave, detailsJSON: detailsJSON)
                await MainActor.run { self.isFavorite = ok }
            }
        }
    }
}


