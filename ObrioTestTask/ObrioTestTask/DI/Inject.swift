//
//  Inject.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import Foundation

@propertyWrapper
struct Inject<Service> {
    var wrappedValue: Service {
        DependencyInjectionContainer.shared.resolve(Service.self)
    }
}

final class DependencyInjectionContainer {
    static let shared = DependencyInjectionContainer()
    private var services = [ObjectIdentifier: Any]()
    private init() {}

    func register<Service>(_ service: Service) {
        let key = ObjectIdentifier(Service.self)
        guard services[key] == nil else {
            print("⚠️ Service \(Service.self) already registered")
            return
        }
        services[key] = service
        print("✅ Registered: \(Service.self)")
    }

    func resolve<Service>(_ type: Service.Type) -> Service {
        let key = ObjectIdentifier(type)
        guard let service = services[key] as? Service else {
            fatalError("❌ Service \(Service.self) is not registered")
        }
        return service
    }
}
