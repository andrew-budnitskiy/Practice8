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

        NavigationView {

            VStack {
                NavigationLink {
                    let viewModel = TestingViewModel()
                    TestingView(withViewModel: viewModel)
                } label: {
                    Text("Экран тестирования")
                        .foregroundColor(.blue)
                        .frame(width: 200,
                               height: 60)
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue,
                                            lineWidth: 1)
                            )
                }
                Spacer()
            }


        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle()).padding(.top, 5)

    }

}
