//
//  DIContainer.swift
//  HRPoll_New
//
//  Created by Andrew on 22.12.2022.
//

import Foundation

// Протокол для реализации DIContainer
protocol DIContainerProtocol {
  func register<Component>(type: Component.Type, component: Any)
  func resolve<Component>(type: Component.Type) -> Component?
}
