//
//  PokemonListReducer.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation

enum PokemonListAction {
    case onAppear
    case refresh
    case loadMore
    case pageResponse(Result<PokemonListResponse, Error>)
    case toggleFavorite(id: Int)
    case favoritesUpdated(Set<Int>)
    case observeFavorites
    case delete(id: Int)
    case dismissError
}

@MainActor
struct PokemonListReducer: ReducerProtocol {
    typealias State = PokemonListState
    typealias Action = PokemonListAction
    typealias Middleware = PokemonListMiddleware

    @Inject private var pokemonService: PokemonServiceProtocol
    @Inject private var favoritesManager: FavoritesManaging

    func reduce(state: PokemonListState, action: PokemonListAction) -> (PokemonListState, PokemonListMiddleware?) {
        var state = state

        switch action {
        case .onAppear:
            guard !state.hasLoadedInitialPage else { return (state, nil) }
            state.hasLoadedInitialPage = true
            state.isInitialLoading = true
            state.errorMessage = nil
            let middleware = PokemonListMiddleware.loadPage(
                service: pokemonService,
                offset: state.offset,
                limit: state.pageLimit
            )
            return (state, middleware)

        case .refresh:
            state.offset = 0
            state.isInitialLoading = true
            state.isPaginating = false
            state.errorMessage = nil
            let middleware = PokemonListMiddleware.loadPage(
                service: pokemonService,
                offset: state.offset,
                limit: state.pageLimit
            )
            return (state, middleware)

        case .loadMore:
            guard state.canLoadMore, !state.isInitialLoading, !state.isPaginating else {
                return (state, nil)
            }
            state.isPaginating = true
            state.errorMessage = nil
            let middleware = PokemonListMiddleware.loadPage(
                service: pokemonService,
                offset: state.offset,
                limit: state.pageLimit
            )
            return (state, middleware)

        case let .pageResponse(result):
            state.isInitialLoading = false
            state.isPaginating = false

            switch result {
            case let .success(response):
                state.totalCount = response.count
                let newItems = response.results.compactMap(PokemonListItem.init)
                if state.offset == 0 {
                    state.items = newItems
                } else {
                    state.items.append(contentsOf: newItems)
                }
                state.offset = state.items.count
                state.errorMessage = nil
                return (state, nil)

            case let .failure(error):
                state.hasLoadedInitialPage = false
                state.errorMessage = error.localizedDescription
                return (state, nil)
            }

        case let .toggleFavorite(id):
            return (state, PokemonListMiddleware.toggleFavorite(manager: favoritesManager, id: id))

        case let .favoritesUpdated(favorites):
            state.favorites = favorites
            return (state, PokemonListMiddleware.observeFavorites(manager: favoritesManager, skipCurrent: true))

        case .observeFavorites:
            guard !state.isObservingFavorites else { return (state, nil) }
            state.isObservingFavorites = true
            state.favorites = favoritesManager.currentFavorites()
            return (state, PokemonListMiddleware.observeFavorites(manager: favoritesManager, skipCurrent: true))

        case let .delete(id):
            state.items.removeAll { $0.id == id }
            return (state, PokemonListMiddleware.removeFavorite(manager: favoritesManager, id: id))

        case .dismissError:
            state.errorMessage = nil
            return (state, nil)
        }
    }
}

