//
//  PokemonDetailState.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation

struct PokemonDetailState: Equatable {
    let id: Int
    let name: String

    var detail: PokemonDetailModel?
    var isLoading = false
    var errorMessage: String?
    var isFavorite = false
    var hasSubscribedToFavorites = false
}
