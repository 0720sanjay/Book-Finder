//
//  BookDoc.swift
//  Book Finder
//
//  Created by Admin on 11/09/25.
//

import Foundation

struct SearchResponse: Codable {
    let docs: [BookDoc]
    let numFound: Int
}

struct BookDoc: Codable, Identifiable {
    var id: String { key }
    
    let title: String?
    let author_name: [String]?
    let cover_i: Int?
    let key: String
    let first_publish_year: Int?
    let isbn: [String]?
}


