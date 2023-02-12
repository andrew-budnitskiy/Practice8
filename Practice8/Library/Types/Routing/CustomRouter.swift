//
//  CustomRouter.swift
//  HRPoll_New
//
//  Created by Andrew on 10.01.2023.
//

import Foundation
import SwiftUI

open class CustomRouter<RouteType: Route>: ObservableObject, Routing {

    public func view(for route: RouteType) -> some View {
        return EmptyView()
    }

    public typealias RouteType = RouteType

    public struct State {
        var pushing: AnyView? = nil
        var presenting: AnyView? = nil
        var isPresented: Binding<Bool>
    }

    @Published public var navigationState: State

    init(isPresented: Binding<Bool> = .constant(false)) {
        navigationState = State(isPresented: isPresented)
    }

}

public extension CustomRouter {

    func push<V: View>(_ view: V) {
        navigationState.pushing = AnyView(view)
        navigationState.isPresented.wrappedValue = true
    }

    func present<V: View>(_ view: V) {
        navigationState.presenting = AnyView(view)
        navigationState.isPresented.wrappedValue = true
    }

    func dismiss() {
        navigationState.pushing = nil
        navigationState.presenting = nil
        navigationState.isPresented.wrappedValue = false
    }
}

public extension CustomRouter {

    var isPushing: Binding<Bool> {
        boolBinding(keyPath: \.pushing)
    }

    var isPresenting: Binding<Bool> {
        boolBinding(keyPath: \.presenting)
    }

    var isPresented: Binding<Bool> {
        navigationState.isPresented
    }
}
