//
//  Routing.swift
//  HRPoll_New
//
//  Created by Andrew on 09.01.2023.
//

import Foundation
import SwiftUI

public protocol Routing: ObservableObject {

    associatedtype RouteType: Route
    associatedtype ViewType: View
    associatedtype NavigationStateType

    var navigationState: NavigationStateType { get set }
    @ViewBuilder func view(for route: RouteType) -> ViewType

}

extension Routing {

    func binding<T>(keyPath: WritableKeyPath<NavigationStateType, T>) -> Binding<T> {
        Binding(
            get: { self.navigationState[keyPath: keyPath] },
            set: { self.navigationState[keyPath: keyPath] = $0 }
        )
    }

    func boolBinding<T>(keyPath: WritableKeyPath<NavigationStateType, T?>) -> Binding<Bool> {
        Binding(
            get: { self.navigationState[keyPath: keyPath] != nil },
            set: {
                if !$0 {
                    self.navigationState[keyPath: keyPath] = nil
                }
            }
        )
    }

}
