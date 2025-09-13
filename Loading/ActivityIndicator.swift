//
//  ActivityIndicator.swift
//  BookFinder
//
//  Created by sci on 13/09/25.
//

import SwiftUI

struct ActivityIndicator: View {
    @Binding var isAnimating: Bool
    var label: String = "Loading..."

    var body: some View {
        if isAnimating {
            VStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .indigo))
                    .scaleEffect(1.4)
                Text(label)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}
