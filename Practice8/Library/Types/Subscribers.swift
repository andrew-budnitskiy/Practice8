//
//  Subscribers.swift
//  HRPoll_New
//
//  Created by Andrew on 23.12.2022.
//

import Foundation
import Combine

// MARK: - GenericSubscriber
class GenericSubscriber<T>: Subscriber {

    typealias Input = T
    typealias Failure = Never
    public private(set) var map: ((Input)->Void)?

    public init(map: ((Input)->Void)? = nil) {
           self.map = map
    }

    func receive(subscription: Subscription) {
           subscription.request(.unlimited)
    }

    func receive(_ input: T) -> Subscribers.Demand {
        self.map?(input)
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        self.map = nil
    }

}

typealias VoidSubscriber = GenericSubscriber<Void>
typealias BoolSubscriber = GenericSubscriber<Bool>
typealias IntSubscriber = GenericSubscriber<Int>
typealias StringSubscriber = GenericSubscriber<String>


