import XCTest
import Combine
@testable import ObrioTestTask

final class PokemonListReducerTests: XCTestCase {
    func testOnAppearTriggersInitialLoad() async throws {
        let service = PokemonServiceMock()
        service.stubbedResponse = PokemonListResponse(count: 1, next: nil, previous: nil, results: [
            .init(name: "bulbasaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/1/")!)
        ])

        let favorites = FavoritesManagerMock()
        let reducer = PokemonListReducer(pokemonService: service, favoritesManager: favorites)
        var state = PokemonListState()

        let (newState, middleware) = reducer.reduce(state: state, action: .onAppear)
        XCTAssertTrue(newState.isInitialLoading)
        XCTAssertNotNil(middleware)
        let action = try await middleware?.run()
        switch action {
        case let .pageResponse(.success(response)):
            XCTAssertEqual(response.results.count, 1)
        default:
            XCTFail("Expected success response")
        }
    }

    func testFavoritesUpdatedKeepsStateInSync() async throws {
        let service = PokemonServiceMock()
        let favorites = FavoritesManagerMock()
        favorites.current = [1]
        let reducer = PokemonListReducer(pokemonService: service, favoritesManager: favorites)
        var state = PokemonListState()

        let (newState, middleware) = reducer.reduce(state: state, action: .observeFavorites)
        XCTAssertEqual(newState.favorites, favorites.currentFavorites())
        let result = try await middleware?.run()
        if case let .favoritesUpdated(favoritesSet)? = result {
            XCTAssertEqual(favoritesSet, favorites.currentFavorites())
        } else {
            XCTFail("Expected favoritesUpdated action")
        }
    }
}

private final class PokemonServiceMock: PokemonServiceProtocol {
    var stubbedResponse: PokemonListResponse?

    func fetchPokemonList(offset: Int, limit: Int) async throws -> PokemonListResponse {
        guard let response = stubbedResponse else {
            throw URLError(.badServerResponse)
        }
        return response
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse {
        throw URLError(.badServerResponse)
    }
}

private final class FavoritesManagerMock: FavoritesManaging {
    var current: Set<Int> = [] {
        didSet { subject.send(current) }
    }
    private let subject = CurrentValueSubject<Set<Int>, Never>([])

    var favoritesPublisher: AnyPublisher<Set<Int>, Never> { subject.eraseToAnyPublisher() }

    func currentFavorites() -> Set<Int> { current }

    func toggle(_ id: Int) { }

    func remove(_ id: Int) { }

    func isFavorite(_ id: Int) -> Bool { current.contains(id) }
}
