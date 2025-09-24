//
//  PokemonDetailReducer.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation

enum PokemonDetailAction {
    case onAppear
    case detailResponse(Result<PokemonDetailResponse, Error>)
    case toggleFavorite
    case favoritesUpdated(Set<Int>)
    case observeFavorites
    case dismissError
}

struct PokemonDetailReducer: ReducerProtocol {
    typealias State = PokemonDetailState
    typealias Action = PokemonDetailAction
    typealias Middleware = PokemonDetailMiddleware

    @Inject private var pokemonService: PokemonServiceProtocol
    @Inject private var favoritesManager: FavoritesManaging


    func reduce(state: PokemonDetailState, action: PokemonDetailAction) -> (PokemonDetailState, PokemonDetailMiddleware?) {
        var state = state

        switch action {
        case .onAppear:
            guard !state.isLoading, state.detail == nil else { return (state, nil) }
            state.isLoading = true
            state.errorMessage = nil
            let middleware = PokemonDetailMiddleware.loadDetail(
                service: pokemonService,
                id: state.id
            )
            return (state, middleware)

        case let .detailResponse(result):
            state.isLoading = false
            switch result {
            case let .success(response):
                let model = PokemonDetailModel(response: response)
                state.detail = model
                state.isFavorite = favoritesManager.isFavorite(model.id)
                if state.hasSubscribedToFavorites {
                    return (state, nil)
                }
                state.hasSubscribedToFavorites = true
                return (state, PokemonDetailMiddleware.observeFavorites(manager: favoritesManager, skipCurrent: true))
            case let .failure(error):
                state.errorMessage = error.localizedDescription
                return (state, nil)
            }

        case .toggleFavorite:
            return (state, PokemonDetailMiddleware.toggleFavorite(manager: favoritesManager, id: state.id))

        case let .favoritesUpdated(favorites):
            state.isFavorite = favorites.contains(state.id)
            return (state, PokemonDetailMiddleware.observeFavorites(manager: favoritesManager, skipCurrent: true))

        case .observeFavorites:
            guard !state.hasSubscribedToFavorites else { return (state, nil) }
            state.hasSubscribedToFavorites = true
            state.isFavorite = favoritesManager.isFavorite(state.id)
            return (state, PokemonDetailMiddleware.observeFavorites(manager: favoritesManager, skipCurrent: true))

        case .dismissError:
            state.errorMessage = nil
            return (state, nil)
        }
    }
}
