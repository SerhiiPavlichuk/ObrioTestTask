//
//  ImageLoader.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import UIKit

protocol ImageLoading {
    func loadImage(from url: URL) async throws -> UIImage
}

actor ImageLoader: ImageLoading {
    private let cache: ImageCache
    private var tasks: [URL: Task<UIImage, Error>] = [:]

    init(cache: ImageCache) {
        self.cache = cache
    }

    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = await cache.image(for: url) {
            return cached
        }

        if let task = tasks[url] {
            return try await task.value
        }

        let task = Task<UIImage, Error> {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            await cache.insert(image, for: url)
            return image
        }

        tasks[url] = task

        defer { tasks[url] = nil }

        do {
            let image = try await task.value
            return image
        } catch {
            throw error
        }
    }
}
