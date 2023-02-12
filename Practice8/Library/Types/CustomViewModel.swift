//
//  CustomViewModel.swift
//  HRPoll_New
//
//  Created by Andrew on 22.12.2022.
//

import Foundation
import Combine
import SwiftUI

open class CustomViewModel<RequestServiceType: RequestService, RouteType: Route>: ViewModel, ObservableObject, CancellablesStore {

    public typealias RequestServiceType = RequestServiceType
    public typealias RouteType = RouteType

    public var bag = Set<AnyCancellable>()

    @Published public var pending: Bool = false
    @Published public var error: Error?
    @Published public var errorCautionHidden: Bool = true

    public var pendingSubject: CurrentValueSubject<AnyPublisher<Bool, Never>, Never> = .init(Just(false).eraseToAnyPublisher())
    public var errorSubject = PassthroughSubject<Error?, Never>()

    public var request: RequestService
    public var route: RouteType.Type

    public init(withRequestService requestService: RequestServiceType = DIContainer.shared.resolve(type: RequestServiceType.self)!,
                         andRoute route: RouteType.Type = DIContainer.shared.resolve(type: RouteType.Type.self)!) {
        self.request = requestService
        self.route = route

        self
            .pendingSubject
            .switchToLatest()
            .assign(to: &self.$pending)

        self
            .errorSubject
            .assign(to: &self.$error)

        self
            .errorSubject
            .map({ error in
                error == nil
            })
            .sink {[weak self] hidden in
                self?.errorCautionHidden = hidden
            }
            .store(in: &self.bag)

    }

}
