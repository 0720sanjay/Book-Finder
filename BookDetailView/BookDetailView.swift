//
//  BookDetailView.swift
//  Book Finder
//
//  Created by Admin on 11/09/25.
//
import SwiftUI

struct BookDetailView: View {
    
    @StateObject private var bookDetailsModel: BookDetailViewModel
    @State private var rotating = false
    
    
    init(book: BookDoc? = nil) {
        let workKey = book?.key ?? ""
        _bookDetailsModel = StateObject(wrappedValue: BookDetailViewModel(workKey: workKey, book: book))
    }
    
    //MARK: Body View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    
                    // Cover Image
                    if let coverId = bookDetailsModel.initialBook?.cover_i {
                        AsyncImage(url: URL(string: "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg")) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.25))
                                    .frame(width: 140, height: 210)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 210)
                                    .cornerRadius(8)
                                    .rotationEffect(.degrees(rotating ? 360 : 0))
                                    .animation(.linear(duration: 12).repeatForever(autoreverses: false), value: rotating)
                            case .failure:
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.25))
                                    .frame(width: 140, height: 210)
                            @unknown default: EmptyView()
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 140, height: 210)
                            .rotationEffect(.degrees(rotating ? 360 : 0))
                            .animation(.linear(duration: 12).repeatForever(autoreverses: false), value: rotating)
                    }
                    
                    Spacer()
                    
                    // MARK: Favorite Button
                    VStack {
                        Button(action: { bookDetailsModel.toggleFavorite() }) {
                            Image(systemName: bookDetailsModel.isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 28, height: 26)
                                .foregroundColor(bookDetailsModel.isFavorite ? .red : .primary)
                        }
                        .padding(.bottom, 8)
                        
                        if bookDetailsModel.isLoading {
                            ProgressView()
                        }
                    }
                }
                
                Text(bookDetailsModel.details?.title ?? bookDetailsModel.initialBook?.title ?? "Unknown title")
                    .font(.title)
                    .bold()
                
                if let authors = bookDetailsModel.initialBook?.author_name?.joined(separator: ", ") {
                    Text(authors)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let desc = bookDetailsModel.details?.description?.value {
                    Text(desc)
                        .font(.body)
                } else if bookDetailsModel.isLoading {
                    Text("Loading description...")
                        .foregroundColor(.secondary)
                }
                
                if let subjects = bookDetailsModel.details?.subjects, !subjects.isEmpty {
                    Text("Subjects").font(.headline)
                    FlowView(tags: subjects)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(bookDetailsModel.details?.title ?? bookDetailsModel.initialBook?.title ?? "Details")
        .onAppear {
            rotating = true
            Task { await bookDetailsModel.fetch() }
        }
    }
}

//MARK: Flowview
struct FlowView: View {
    let tags: [String]
    var body: some View {
        FlexibleView(data: tags, spacing: 8, alignment: .leading) { text in
            Text(text)
                .font(.caption)
                .padding(6)
                .background(Color(.secondarySystemFill))
                .cornerRadius(6)
        }
    }
}

//MARK: FlexibleView
struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            self.generateContent(in: proxy.size)
        }
        .frame(minHeight: 0, maxHeight: .infinity)
    }
    
    private func generateContent(in size: CGSize) -> some View {
        var width = CGFloat.zero
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        
        for item in data {
            let itemStr = "\(item)"
            let itemWidth = itemStr.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)]).width + 32
            if width + itemWidth + spacing > size.width {
                currentRow += 1
                rows.append([item])
                width = itemWidth
            } else {
                rows[currentRow].append(item)
                width += itemWidth + spacing
            }
        }
        
        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { r in
                HStack(spacing: spacing) {
                    ForEach(rows[r], id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

