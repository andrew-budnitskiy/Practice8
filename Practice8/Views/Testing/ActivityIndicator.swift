//
//  ActivityIndicator.swift
//  Practice8
//
//  Created by Andrew on 03.03.2023.
//

import Foundation
import SwiftUI

struct ActivityIdicator: ViewModifier {

    let tintColor: Color
    let hidden: Bool

    func body(content: Content) -> some View {

        VStack(alignment: .center) {
            content
            if !self.hidden {
                ProgressView()
                    .scaleEffect(1.0, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
            }
        }

    }

}
