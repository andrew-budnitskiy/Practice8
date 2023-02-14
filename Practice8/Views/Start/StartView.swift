//
//  StartView.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 14.02.2023.
//

import Foundation
import SwiftUI

struct StartView: View, ViewModelled {

    @ObservedObject private(set) var viewModel: StartViewModel

    init(withViewModel viewModel: StartViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        VStack {
            Button {

            } label: {
                Text("Экран тестирования")
                    .foregroundColor(.blue)
                    .frame(width: 200,
                           height: 60,
                           alignment: .center)
            }
            .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue,
                                lineWidth: 1)
                )

        }

    }

}