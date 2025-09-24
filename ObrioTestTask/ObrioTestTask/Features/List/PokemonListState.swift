//
//  PokemonListState.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation

struct PokemonListState: Equatable {
    var items: [PokemonListItem] = []
    var favorites: Set<Int> = []
    var isInitialLoading = false
    var isPaginating = false
    var offset = 0
    var totalCount: Int?
    var errorMessage: String?
    var hasLoadedInitialPage = false
    var isObservingFavorites = false

    let pageLimit = 20

    var favoritesCount: Int { favorites.count }
    var canLoadMore: Bool {
        guard let totalCount else { return true }
        return items.count < totalCount
    }
}
