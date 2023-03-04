//
//  TestingView.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 15.02.2023.
//

import Foundation
import SwiftUI
// Основной рабочий экран
struct TestingView: View, ViewModelled {

    @ObservedObject private(set) var viewModel: TestingViewModel

    init(withViewModel viewModel: TestingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

            VStack {
                HStack {
                    Text("\(self.viewModel.lastUpdate)")
                        .frame(alignment: .leading)
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                        .background(.yellow)
                    Spacer()
                }
                .padding(.leading, 20)
                .frame(maxWidth: .infinity)
                .modifier(ActivityIdicator(tintColor: .gray,
                                           hidden: !self.viewModel.pending))
                ScrollView {
                    ForEach(self.viewModel.list) { item in
                        let cellViewModel = NewsCellViewModel(withData: item)
                        NewsCell(withViewModel: cellViewModel)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .onAppear {
                    self
                        .viewModel
                        .executeCacheRequest()
                }
                Spacer()
        }
        .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Обновить") {
                        self
                            .viewModel
                            .execute()
                    }
                }
        }

    }
}
