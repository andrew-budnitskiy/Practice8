//
//  Practice8App.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 12.02.2023.
//

import SwiftUI
import AlamofireNetworkActivityLogger

@main
struct Practice8App: App {
    var body: some Scene {

    #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
    #endif

    DIContainer.shared.register(type: CustomRequestService.self,
                                component: CustomRequestService())
        return WindowGroup {
            StartView(withViewModel: .init())
        }
    }
}
