//
//  NewsCell.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 04.03.2023.
//

import Foundation
import UIKit
import SwiftUI

struct NewsCell: View, ViewModelled {

    @ObservedObject private(set) var viewModel: NewsCellViewModel

    init(withViewModel viewModel: NewsCellViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        VStack(alignment: .leading) {

            Text("\(self.viewModel.data?.domain ?? "")")
                .font(.system(size: 12,
                              weight: .bold))
                .foregroundColor(.black)


            Text("\(self.viewModel.data?.categories ?? "")")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.top, 2)
                .background(.green)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray,
                            lineWidth: 1)
            )


    }

}
