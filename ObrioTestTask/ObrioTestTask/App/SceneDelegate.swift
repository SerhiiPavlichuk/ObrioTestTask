//
//  SceneDelegate.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let reducer = PokemonListReducer()
        let store = Store(initialState: PokemonListState(), reducer: reducer)
        let listController = PokemonListViewController(store: store)
        let navigationController = UINavigationController(rootViewController: listController)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}
