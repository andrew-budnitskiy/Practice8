//
//  SheetModifier.swift
//  HRPoll_New
//
//  Created by Andrew on 10.01.2023.
//

import Foundation
import SwiftUI

struct PresentModifier: ViewModifier {

    @Binding var presentingView: AnyView?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: Binding(
                get: { self.presentingView != nil },
                set: { if !$0 {
                    self.presentingView = nil
                }})
            ) {
                self.presentingView
            }

    }
}
