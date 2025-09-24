//
//  PokemonModels.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation

struct PokemonListResponse: Decodable {
    struct Result: Decodable {
        let name: String
        let url: URL
    }

    let count: Int
    let next: String?
    let previous: String?
    let results: [Result]
}

struct PokemonListItem: Identifiable, Equatable {
    let id: Int
    let name: String

    init?(result: PokemonListResponse.Result) {
        guard let id = Self.extractID(from: result.url) else {
            return nil
        }
        self.id = id
        self.name = result.name.capitalized
    }

    private static func extractID(from url: URL) -> Int? {
        let idComponent = url.pathComponents.compactMap { Int($0) }.last
        return idComponent
    }
}

struct PokemonDetailResponse: Decodable {
    struct Sprites: Decodable {
        struct Other: Decodable {
            struct OfficialArtwork: Decodable {
                let frontDefault: URL?
            }

            let officialArtwork: OfficialArtwork?

            private enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }
        }

        let other: Other?
        let frontDefault: URL?
    }

    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
}

struct PokemonDetailModel: Equatable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let imageURL: URL?

    init(response: PokemonDetailResponse) {
        id = response.id
        name = response.name.capitalized
        height = response.height
        weight = response.weight
        imageURL = response.sprites.other?.officialArtwork?.frontDefault ?? response.sprites.frontDefault
    }
}

extension PokemonDetailModel {
    var formattedHeight: String {
        String(format: "%.1f m", Double(height) / 10.0)
    }

    var formattedWeight: String {
        String(format: "%.1f kg", Double(weight) / 10.0)
    }
}

extension PokemonListItem {
    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}
