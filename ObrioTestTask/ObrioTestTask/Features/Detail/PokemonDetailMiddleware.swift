//
//  PokemonDetailMiddleware.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation
import Combine

enum PokemonDetailMiddleware: MiddlewareProtocol {
    case loadDetail(service: PokemonServiceProtocol, id: Int)
    case observeFavorites(manager: FavoritesManaging, skipCurrent: Bool)
    case toggleFavorite(manager: FavoritesManaging, id: Int)

    func run() async throws -> PokemonDetailAction? {
        switch self {
        case let .loadDetail(service, id):
            do {
                let response = try await service.fetchPokemonDetail(id: id)
                return .detailResponse(.success(response))
            } catch {
                return .detailResponse(.failure(error))
            }

        case let .observeFavorites(manager, skipCurrent):
            let publisher = manager.favoritesPublisher.dropFirst(skipCurrent ? 1 : 0)
            for await favorites in publisher.values {
                return .favoritesUpdated(favorites)
            }
            return nil

        case let .toggleFavorite(manager, id):
            manager.toggle(id)
            return nil
        }
    }
}

