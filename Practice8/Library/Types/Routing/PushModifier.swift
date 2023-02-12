//
//  PushModifier.swift
//  HRPoll_New
//
//  Created by Andrew on 10.01.2023.
//

import Foundation
import SwiftUI

struct PushModifier: ViewModifier {

    @Binding var presentingView: AnyView?

    func body(content: Content) -> some View {
        content
            .background(
                NavigationLink(destination: self.presentingView, isActive: Binding(
                    get: { self.presentingView != nil },
                    set: { if !$0 {
                        self.presentingView = nil
                    }})
                ) {
                    EmptyView()
                }
            )
    }
}
