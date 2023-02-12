//
//  RequestService.swift
//  HRPoll_New
//
//  Created by Andrew on 22.12.2022.
//

import Foundation

public protocol RequestService: Initializable {

    var http: CustomHttpAfService { get }
    var userDefaults: CustomUserDefaultsService { get }
    var keychain: CustomKeychainService { get }

}
