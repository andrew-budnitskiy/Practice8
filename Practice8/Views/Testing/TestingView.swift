//
//  TestingView.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 15.02.2023.
//

import Foundation
import SwiftUI

struct TestingView: View, ViewModelled {

    @ObservedObject private(set) var viewModel: TestingViewModel

    init(withViewModel viewModel: TestingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        VStack {

            Button("Запрос") {
                self.viewModel.execute()
            }
            .frame(height: 50)

            .modifier(ActivityIdicator(tintColor: .gray,
                                       hidden: !self.viewModel.pending))

            ScrollView {

                ForEach(self.viewModel.list) { item in
                    Text("asd")
                }
            }



        }

    }

}
