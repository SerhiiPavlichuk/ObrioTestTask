//
//  PokemonListMiddleware.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation
import Combine

enum PokemonListMiddleware: MiddlewareProtocol {
    case loadPage(service: PokemonServiceProtocol, offset: Int, limit: Int)
    case observeFavorites(manager: FavoritesManaging, skipCurrent: Bool)
    case toggleFavorite(manager: FavoritesManaging, id: Int)
    case removeFavorite(manager: FavoritesManaging, id: Int)

    func run() async throws -> PokemonListAction? {
        switch self {
        case let .loadPage(service, offset, limit):
            do {
                let response = try await service.fetchPokemonList(offset: offset, limit: limit)
                return .pageResponse(.success(response))
            } catch {
                return .pageResponse(.failure(error))
            }

        case let .observeFavorites(manager, skipCurrent):
            let publisher: AnyPublisher<Set<Int>, Never> = skipCurrent ? manager.favoritesPublisher.dropFirst().eraseToAnyPublisher() : manager.favoritesPublisher
            for await favorites in publisher.values {
                return .favoritesUpdated(favorites)
            }
            return nil

        case let .toggleFavorite(manager, id):
            manager.toggle(id)
            return nil

        case let .removeFavorite(manager, id):
            manager.remove(id)
            return nil
        }
    }
}

