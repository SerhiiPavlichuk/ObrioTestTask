//
//  ImageCache.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import UIKit

actor ImageCache {
    private let capacity: Int
    private var storage: [URL: UIImage] = [:]
    private var ordering: [URL] = []

    init(capacity: Int = 20) {
        self.capacity = max(1, capacity)
    }

    func image(for url: URL) -> UIImage? {
        guard let image = storage[url] else { return nil }
        touch(url)
        return image
    }

    func insert(_ image: UIImage, for url: URL) {
        storage[url] = image
        touch(url)
        trimIfNeeded()
    }

    private func touch(_ url: URL) {
        ordering.removeAll { $0 == url }
        ordering.append(url)
    }

    private func trimIfNeeded() {
        guard storage.count > capacity, let oldest = ordering.first else { return }
        storage.removeValue(forKey: oldest)
        ordering.removeFirst()
    }
}
