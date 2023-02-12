//
//  ServiceLocator.swift
//  HRPoll_New
//
//  Created by Andrew on 22.12.2022.
//

import Foundation

// DIContainer. Реализация соответствующего протокола.
// В нем регистрируются все зависимости в проекте
// Реализуется как синглтон, чтобы источник заисимостей был в единственном экземпляре.
public final class DIContainer: DIContainerProtocol {

    public static let shared = DIContainer()
    private init() {}

    var components: [String: Any] = [:]

    // Метод регистрации зависимости
    public func register<Component>(type: Component.Type, component: Any) {
        components["\(type)"] = component
    }

    // Метод получения зависимости по типу
    public func resolve<Component>(type: Component.Type) -> Component? {
        return components["\(type)"] as? Component
    }
}
