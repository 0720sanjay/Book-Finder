//
//  OpenLibraryService.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.
//

import Foundation


final class OpenLibraryService {
    
    private let searchBaseURL = "https://openlibrary.org/search.json"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Search Books
    func searchBooks(title: String, page: Int = 1) async throws -> SearchResponse {
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(searchBaseURL)?title=\(encodedTitle)&page=\(page)") else {
            throw URLError(.badURL)
        }
        
        print("API Search URL:", url)
        
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(SearchResponse.self, from: data)
        return response
    }
    
    // MARK: - Fetch Work Details
    func fetchWorkDetails(workKey: String) async throws -> WorkDetails {
        guard let url = URL(string: "https://openlibrary.org\(workKey).json") else {
            throw URLError(.badURL)
        }
        
        print("API Details URL:", url)
        
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        let details = try decoder.decode(WorkDetails.self, from: data)
        return details
    }
}
