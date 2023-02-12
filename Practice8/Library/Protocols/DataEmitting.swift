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

public protocol DataEmitting {
    associatedtype DataType
    var dataSubject: PassthroughSubject<DataType, Never> { get }
}

extension DataEmitting {
    var data: AnyPublisher<DataType, Never> {
        self.dataSubject.eraseToAnyPublisher()
    }

    func bindEmission(to subscriber: GenericSubscriber<DataType>) -> Self {
        let copy = self
        
        self.dataSubject.subscribe(subscriber)
        copy.data.subscribe(subscriber)
        return copy
    }

    func emitData(_ value: DataType) {
        dataSubject.send(value)
    }
}

public protocol StringEmitting: DataEmitting where DataType == String {}
public protocol IntEmitting: DataEmitting where DataType == Int {}

public protocol VoidEmitting: DataEmitting where DataType == Void {}
extension VoidEmitting {
    func emitData() {
        self.emitData(())
    }
}

