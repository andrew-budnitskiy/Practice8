//
//  ConfigInstance.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation

public enum ConfigValue<T> {
    case test(value: T)
    case production(value: T)
}

public protocol ConfigReflector {}
public extension ConfigReflector {
    fileprivate var testMode: Bool {
        return CustomSettings.testMode
    }
}

public protocol ConfigReflectable: ConfigReflector {

    associatedtype T
    func setValue(_ value: ConfigValue<T>)
    func setValue(_ value: T)
    var value: T { get }

}

public class ConfigInstance<T> {
    private var valueTest: T
    private var valueProduction: T
    public init(_ defaultValue: T) {
        self.valueTest = defaultValue
        self.valueProduction = defaultValue
    }
}

extension ConfigInstance: ConfigReflectable {

    public var value: T {
        return testMode
        ? self.valueTest
        : self.valueProduction
    }

    public func setValue(_ value: ConfigValue<T>) {
        switch value {
        case .test(let value):
            self.valueTest = value
        case .production(let value):
            self.valueProduction = value
        }
    }

    public func setValue(_ value: T) {
        self.valueTest = value
        self.valueProduction = value
    }

}
