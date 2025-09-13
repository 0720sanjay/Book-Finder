//
//  Untitled.swift
//  BookFinder
//
//  Created by sci on 13/09/25.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.favoriteBooks.isEmpty {
                    VStack(spacing: 5) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No favorite books yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else {
                    //MARK: Favorites List.
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.favoriteBooks, id: \.workKey) { book in
                            let bookDoc = BookDoc(
                                title: book.title,
                                author_name: book.authors.isEmpty ? nil : book.authors.components(separatedBy: ", "),
                                cover_i: book.coverId,
                                key: "/works/\(book.workKey)",
                                first_publish_year: nil,
                                isbn: nil
                            )
                            
                            //MAR: Send Next viewcontroller
                            NavigationLink(destination: BookDetailView(book: bookDoc)) {
                                BookCardView(book: bookDoc)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchFavorites()
        }
    }
}
