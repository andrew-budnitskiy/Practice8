//
//  HttpAfRequestParams.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation
import Alamofire

public class HttpAfRequestParams {

    private(set) var params: [String: Any]?
    private(set) var requestMethod: HTTPMethod
    private(set) var url: String
    private(set) var paramsEncoding: ParameterEncoding
    private(set) var validation: [Int] = [Int].init(200..<301)
    private(set) var timeout: TimeInterval

    public var headers: HTTPHeaders

    private static func defaultParameterEncoding(byRequestMethod requestMethod: HTTPMethod) -> ParameterEncoding {

        switch requestMethod {

        case .post, .delete, .put:
            return JSONEncoding(options: .prettyPrinted)
        default:
            return URLEncoding.default

        }

    }

    public init(withUrl url: String,
         withParams params: [String: Any]?,
                         withRequestMethod method: HTTPMethod,
                         withParamsEncoding encoding: ParameterEncoding? = nil,
                         withHeaders headers: HTTPHeaders = HTTPHeaders(),
                         withValidation validation: [Int]? = nil,
                withTimeout timeout: TimeInterval = CustomSettings.http.timeout) {

        self.params = params
        self.headers = headers
        self.requestMethod = method
        self.url = url
        self.paramsEncoding = encoding ?? HttpAfRequestParams.defaultParameterEncoding(byRequestMethod: method)
        self.validation = validation ?? self.validation
        self.timeout = timeout

    }



}
