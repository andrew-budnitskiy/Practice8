//
//  NewsCellViewModel.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 04.03.2023.
//

import Foundation

class NewsCellViewModel: PracticeViewModel {

    private(set) var data: TheNewsApiSource?
    convenience init(withData data: TheNewsApiSource) {
        self.init()
        self.data = data
    }

}
