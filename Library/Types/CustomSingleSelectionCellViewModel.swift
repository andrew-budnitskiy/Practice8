//
//  CustomSingleSelectionCellViewModel.swift
//  HRPoll_New
//
//  Created by Andrew on 19.01.2023.
//

import Foundation
import SwiftUI

class CustomSingleSelectionCellViewModel<DataType: Equatable,
                                            RequestServiceType: RequestService>: CustomViewModel<RequestServiceType> {

    private(set) var data: DataType? = nil
    private var selectionKeeper: Binding<DataType?> = .constant(nil)

    convenience init(withData data: DataType,
         withSelectionKeeper selectionKeeper: Binding<DataType?>,
         withRequestService requestService: RequestServiceType = DIContainer.shared.resolve(type: RequestServiceType.self)!) {
        self.init(withRequestService: requestService)
        self.data = data
        self.selectionKeeper = selectionKeeper
    }

}

extension CustomSingleSelectionCellViewModel {

    func select() {
        self.selectionKeeper.wrappedValue = data
    }

    var selected: Bool {
        return self.data == self.selectionKeeper.wrappedValue
    }

    var iconName: String {
        return self.selected ? "checkmark" : ""
    }

}
