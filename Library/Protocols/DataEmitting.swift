//
//  DataEmitting.swift
//  HRPoll_New
//
//  Created by Andrew on 26.12.2022.
//

import Foundation
import Combine


public protocol CancellablesStore {
    var bag: Set<AnyCancellable> { get set }
    mutating func resetBag()
}
public extension CancellablesStore {
    mutating func resetBag() {
        self.bag = Set<AnyCancellable>()
    }
}
