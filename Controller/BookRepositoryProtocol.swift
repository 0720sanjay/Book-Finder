//
//  BookRepositoryProtocol.swift
//  Book Finder
//
//  Created by Admin on 11/09/25.

import Foundation

protocol BookRepositoryProtocol {
    func save(_ book: BookDoc)
    func delete(_ book: BookDoc)
    func saveFavorite(book: BookDoc, detailsJSON: String?) -> Bool
    func deleteFavorite(workKey: String) -> Bool
    func fetchAll() -> [BookDoc]
    func isFavorite(_ book: BookDoc) -> Bool
}
