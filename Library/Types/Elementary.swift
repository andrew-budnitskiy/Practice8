//
//  Elementary.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation
import UIKit

//MARK: - Settings
public class UrlSettings {
    public var main: ConfigInstance = .init("")
    public var auth: ConfigInstance = .init("")
}

public class HeadersSettings {
    public var main: ConfigInstance = .init([String: Any]())
    public var auth: ConfigInstance = .init([String: Any]())
}

public class ParamsSettings {
    public lazy var main: ConfigInstance = {.init([String: Any]())}()
    public lazy var auth: ConfigInstance = {.init([String: Any]())}()
}

public class HttpSettings {
    public lazy var url: UrlSettings = { .init() }()
    public lazy var headers: HeadersSettings = { .init() }()
    public lazy var params: ParamsSettings = { .init() }()
    public var timeout: TimeInterval = CommonConstants.Http.timeout
}

public class DesignSettings {
    public var notifications: [NotificationDesignParams] = []
}


public class CustomSettings {
    public static var testMode: Bool = false
    public static var http: HttpSettings = .init()
    public static var design: DesignSettings = .init()
}

// MARK: - TypeAliases
public typealias HttpResponseStatusHandler = (Int, Any?) throws -> Void
