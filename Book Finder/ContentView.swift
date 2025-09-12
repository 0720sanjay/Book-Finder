//
//  ContentView.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var serachModel = SearchViewModel()
    @State private var hasSearched = false
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {

                // MARK: Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search books...", text: $serachModel.query)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)

                // MARK: Search Button
                Button(action: {
                    hasSearched = true
                    Task { await serachModel.search() }
                }) {
                    Text("Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // MARK: Scrollable View
                ScrollView {
                    VStack(spacing: 16) {
                        if serachModel.isLoading && serachModel.books.isEmpty {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(0..<6, id: \.self) { _ in
                                    BookCardShimmer()
                                        .redacted(reason: .placeholder)
                                }
                            }
                        } else if hasSearched && serachModel.books.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No books found")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(serachModel.books) { book in
                                    NavigationLink(destination: BookDetailView(book: book)) {
                                        BookCardView(book: book)
                                    }
                                    .onAppear {
                                        Task { await serachModel.loadMoreIfNeeded(currentBook: book) }
                                    }
                                }

                                if serachModel.isLoadingMore {
                                    ProgressView("Loading more...")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
                .refreshable {
                    let trimmedQuery = serachModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedQuery.isEmpty {
                        await serachModel.search(reset: true)
                    }
                }

            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Book Finder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
