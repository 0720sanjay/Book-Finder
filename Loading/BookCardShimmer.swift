//
//  BookRowShimmer.swift
//  Book Finder
//
//  Created by Admin on 10/09/25.

import SwiftUI

//MARK: Book Card Shimmer

struct BookCardShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 150)
                .cornerRadius(8)

            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 20)
                .cornerRadius(4)

            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .cornerRadius(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}



