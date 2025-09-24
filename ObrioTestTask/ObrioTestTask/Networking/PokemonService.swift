//
//  PokemonService.swift
//  ObrioTestTask
//
//  Created by Serhii on 2025-09-24.
//

import Foundation

protocol PokemonServiceProtocol {
    func fetchPokemonList(offset: Int, limit: Int) async throws -> PokemonListResponse
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse
}

struct PokemonService: PokemonServiceProtocol {
    private let listNetwork = NetworkManager<PokemonListResponse, PokemonEndpoints>()
    private let detailNetwork = NetworkManager<PokemonDetailResponse, PokemonEndpoints>()

    func fetchPokemonList(offset: Int, limit: Int) async throws -> PokemonListResponse {
        try await listNetwork.request(endpoint: .list(offset: offset, limit: limit))
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse {
        try await detailNetwork.request(endpoint: .detail(id: id))
    }
}
