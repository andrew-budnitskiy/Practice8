//
//  FlowState.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation

public enum Flow {
    case idle
    case pending
    case data(data: Any?)
}

extension Flow: Equatable {
    public static func == (lhs: Flow, rhs: Flow) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
            (.pending, pending),
            (.data, .data):
            return true
        default:
            return false
        }
    }
}

extension Flow: Pending {
    public var pending: Bool {
        self == .pending
    }
}
