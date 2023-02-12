//
//  ViewModel.swift
//  HRPoll_New
//
//  Created by Andrew on 22.12.2022.
//

import Foundation
import Combine

public protocol ViewModel {

    associatedtype RequestServiceType: RequestService
    associatedtype RouteType: Route

    var pending: Bool { get set }

    var request: RequestService { get set }
    var route: RouteType.Type { get set }

}
