//
//  FavoritesManager.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation
import Combine

protocol FavoritesManaging {
    var favoritesPublisher: AnyPublisher<Set<Int>, Never> { get }
    func currentFavorites() -> Set<Int>
    func toggle(_ id: Int)
    func remove(_ id: Int)
    func isFavorite(_ id: Int) -> Bool
}

final class FavoritesManager: FavoritesManaging {
    private let queue = DispatchQueue(label: "FavoritesManagerQueue")
    private var favorites: Set<Int> = []
    private let subject = CurrentValueSubject<Set<Int>, Never>([])
    private let storageKey = "pokemon_favorites_ids"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let stored = userDefaults.array(forKey: storageKey) as? [Int] {
            favorites = Set(stored)
            subject.send(favorites)
        }
    }

    var favoritesPublisher: AnyPublisher<Set<Int>, Never> {
        subject.eraseToAnyPublisher()
    }

    func currentFavorites() -> Set<Int> {
        queue.sync { favorites }
    }

    func toggle(_ id: Int) {
        queue.async { [weak self] in
            guard let self else { return }
            if self.favorites.contains(id) {
                self.favorites.remove(id)
            } else {
                self.favorites.insert(id)
            }
            self.subject.send(self.favorites)
            self.persistFavorites()
        }
    }

    func remove(_ id: Int) {
        queue.async { [weak self] in
            guard let self, self.favorites.contains(id) else { return }
            self.favorites.remove(id)
            self.subject.send(self.favorites)
            self.persistFavorites()
        }
    }

    func isFavorite(_ id: Int) -> Bool {
        queue.sync { favorites.contains(id) }
    }

    private func persistFavorites() {
        userDefaults.set(Array(favorites), forKey: storageKey)
    }
}
