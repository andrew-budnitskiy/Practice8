//
//  CustomRequestService.swift
//  HRPoll_New
//
//  Created by Andrew on 22.12.2022.
//

import Foundation

open class CustomRequestService: RequestService {

    public private(set) lazy var http: CustomHttpAfService = {
        .init()
    }()

    public private(set) lazy var userDefaults: CustomUserDefaultsService = {
        .init()
    }()

    public private(set) lazy var keychain: CustomKeychainService = {
        .init()
    }()

    required public init() {}

}
