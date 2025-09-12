//
//  BookRowView.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.

import SwiftUI

//MARK: Book Card View
struct BookCardView: View {
    let book: BookDoc

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: coverURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "book")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
            .frame(height: 150)
            .cornerRadius(8)
            .clipped()

            Text(book.title ?? "Untitled")
                .font(.headline)
                .lineLimit(2)

            Text(book.author_name?.first ?? "Unknown Author")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var coverURL: URL? {
        guard let coverID = book.cover_i else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")
    }
}
