//
//  ErrorHeaderable.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation

public protocol ErrorHeaderReadable {
    var errorHeader: String { get }
}

extension ErrorHeaderReadable {

    public var errorHeader: String {
        return String(describing: self)
    }

    func error(withMessage message: String) -> Error {
        return CommonErrors.Custom.onOwner(owner: self,
                                           message: message)
    }

}
