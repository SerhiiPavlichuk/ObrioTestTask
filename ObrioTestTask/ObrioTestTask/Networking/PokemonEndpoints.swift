//
//  PokemonEndpoints.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import Foundation

enum PokemonEndpoints {
    case list(offset: Int, limit: Int)
    case detail(id: Int)
}

extension PokemonEndpoints: APIEndpoint {
    var baseURL: URL {
        URL(string: "https://pokeapi.co/api/v2")!
    }
    
    var path: String {
        switch self {
        case .list:
            return "/pokemon"
        case let .detail(id):
            return "/pokemon/\(id)"
        }
    }
    
    var method: HTTPMethod { .get }
    
    var headers: [String: String]? {
        ["Accept": "application/json"]
    }
    
    var bodyParameters: [String: Any]? { nil }

    var urlParameters: [String: String]? {
        switch self {
        case let .list(offset, limit):
            return [
                "offset": String(offset),
                "limit": String(limit)
            ]
        case .detail:
            return nil
        }
    }
}
