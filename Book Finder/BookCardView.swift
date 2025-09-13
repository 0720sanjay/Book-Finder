//
//  BookRowView.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.

import SwiftUI

//MARK: Book Card View
struct BookCardView: View {
    let book: BookDoc
    private let cardHeight: CGFloat = 260
    private let coverHeight: CGFloat = 150

    var body: some View {
        VStack(spacing: 8) {
            cover
            title
            author
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Cover
    private var cover: some View {
        AsyncImage(url: coverURL) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Image(systemName: "book")
                        .font(.largeTitle)
                        .foregroundColor(.white))
            case .success(let img):
                img
                    .resizable()
                    .scaledToFit()
            case .failure:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Image(systemName: "book")
                        .font(.largeTitle)
                        .foregroundColor(.white))
            @unknown default: EmptyView()
            }
        }
        .frame(height: coverHeight)
        .cornerRadius(8)
        .clipped()
    }

    // MARK: - Title
    private var title: some View {
        Text(book.title ?? "Untitled")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.blue)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
    }

    // MARK: - Author
    private var author: some View {
        Text(book.author_name?.first ?? "Unknown Author")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }

    private var coverURL: URL? {
        guard let id = book.cover_i else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(id)-L.jpg")
    }
}
