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
        NavigationStack {
            VStack(spacing: 15) {

                // MARK: Search Bar
                HStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search books...", text: $serachModel.query)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.leading, 12)
                    .frame(height: 48)
                    .background(Color(.systemGray6))

                    Button(action: {
                        hasSearched = true
                        Task { await serachModel.search() }
                    }) {
                        Text("Search")
                            .fontWeight(.semibold)
                            .frame(width: 80, height: 48)
                            .background(Color.indigo)
                            .foregroundColor(.white)
                    }
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 20)

                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 20)

                // MARK: Books list
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
                            VStack(spacing: 5) {
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
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .refreshable {
                    let trimmedQuery = serachModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedQuery.isEmpty {
                        await serachModel.search(reset: true)
                    }
                }

            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Book Finder")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.indigo, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}



#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
