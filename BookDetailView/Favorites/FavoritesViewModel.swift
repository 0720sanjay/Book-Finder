//
//  FavoritesViewModel.swift
//  BookFinder
//
//  Created by sci on 13/09/25.
//

import Foundation
import SwiftUI

final class FavoritesViewModel: ObservableObject {
    @Published var favoriteBooks: [FavoriteBook] = []

    //MARK: Fetch Fav List
    func fetchFavorites() {
        favoriteBooks = SQLiteManager.shared.fetchAllFavorites()
    }
}
