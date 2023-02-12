//
//  CustomSingleSelectionCellViewModel.swift
//  HRPoll_New
//
//  Created by Andrew on 19.01.2023.
//

import Foundation
import SwiftUI

class CustomSingleSelectionCellViewModel<DataType: Equatable,
                                            RequestServiceType: RequestService,
                                         RouteType: Route>: CustomViewModel<RequestServiceType, RouteType> {

    private(set) var data: DataType? = nil
    private var selectionKeeper: Binding<DataType?> = .constant(nil)

    convenience init(withData data: DataType,
         withSelectionKeeper selectionKeeper: Binding<DataType?>,
         withRequestService requestService: RequestServiceType = DIContainer.shared.resolve(type: RequestServiceType.self)!,
         withRoute route: RouteType.Type = DIContainer.shared.resolve(type: RouteType.Type.self)!) {
        self.init(withRequestService: requestService, andRoute: route)
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
