//
//  MiddlewareProtocol.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import Foundation
import Combine

protocol MiddlewareProtocol {
    associatedtype StateAction
    func run() async throws -> StateAction?
}

struct EmptyMiddleware<Action>: MiddlewareProtocol {
    func run() async throws -> Action? { nil }
}

@MainActor
protocol ReducerProtocol {
    associatedtype State
    associatedtype Action
    associatedtype Middleware: MiddlewareProtocol where Middleware.StateAction == Action

    func reduce(state: State, action: Action) -> (State, Middleware?)
}

@MainActor
final class Store<R: ReducerProtocol>: ObservableObject {
    @Published private(set) var state: R.State
    private let reducer: R

    init(initialState: R.State, reducer: R) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: R.Action) {
        let (newState, middleware) = reducer.reduce(state: state, action: action)
        state = newState

        guard let middleware else { return }
        Task { [weak self] in
            guard let next = try await middleware.run() else { return }
            self?.send(next) 
        }
    }
}
