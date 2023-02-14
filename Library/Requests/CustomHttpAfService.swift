//
//  CustomHttpAfService.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation
import Alamofire
import Combine
import CoreData
import UIKit

open class CustomHttpAfService {


    open func executeWrapped<ResultType: Decodable>(withParams params: HttpAfRequestParams,
                                             withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<AnyPublisher<ResultType, Error>, Never> {

        let result: AnyPublisher<ResultType, Error> = self.createAndValidateRequest(withParams: params,
                                             withResponseStatusHandler: responseStatusHandler)
        return self.wrap(result)

    }

    open func execute<ResultType: Decodable>(withParams params: HttpAfRequestParams,
                                             withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) ->  AnyPublisher<ResultType, Error> {

        return self.createAndValidateRequest(withParams: params,
                                             withResponseStatusHandler: responseStatusHandler)

    }

    open func executeWrapped(withParams params: HttpAfRequestParams,
                             withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<AnyPublisher<Data, Error>, Never> {

        let result: AnyPublisher<Data, Error> = self.createAndValidateRequest(withParams: params,
                                                                              withResponseStatusHandler: responseStatusHandler)
        return self.wrap(result)

    }

    open func execute(withParams params: HttpAfRequestParams,
                                             withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<Data, Error> {

        return self.createAndValidateRequest(withParams: params,
                                             withResponseStatusHandler: responseStatusHandler)

    }


    open func executeWrapped(withParams params: HttpAfRequestParams,
                             withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<AnyPublisher<Void, Error>, Never> {

        let result: AnyPublisher<Void, Error> = self.createAndValidateRequest(withParams: params,
                                                                              withResponseStatusHandler: responseStatusHandler)
        return self.wrap(result)

    }

    open func execute(withParams params: HttpAfRequestParams,
                                             withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<Void, Error> {

        return self.createAndValidateRequest(withParams: params,
                                             withResponseStatusHandler: responseStatusHandler)

    }

    open func uploadWrapped<ResultType: Decodable>(fileUrl: URL,
                                            withParams params: HttpAfRequestParams,
                                            withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<AnyPublisher<ResultType, Error>, Never> {

        let result: AnyPublisher<ResultType, Error> = self.createAndValidateUpload(fileUrl: fileUrl,
                                                                                   withParams: params,
                                                                                   withResponseStatusHandler: responseStatusHandler)
        return self.wrap(result)

    }

    open func upload<ResultType: Decodable>(fileUrl: URL,
                                            withParams params: HttpAfRequestParams,
                                            withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<ResultType, Error> {

        return self.createAndValidateUpload(fileUrl: fileUrl,
                                            withParams: params,
                                            withResponseStatusHandler: responseStatusHandler)

    }

    open func uploadWrapped(fileUrl: URL,
                            withParams params: HttpAfRequestParams,
                            withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<AnyPublisher<Void, Error>, Never> {

        let result: AnyPublisher<Void, Error> = self.createAndValidateUpload(fileUrl: fileUrl,
                                                                             withParams: params,
                                                                             withResponseStatusHandler: responseStatusHandler)

        return self.wrap(result)

    }

    open func upload(fileUrl: URL,
                     withParams params: HttpAfRequestParams,
                     withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> AnyPublisher<Void, Error> {

        return self.createAndValidateUpload(fileUrl: fileUrl,
                                            withParams: params,
                                            withResponseStatusHandler: responseStatusHandler)

    }


}

extension CustomHttpAfService {

    private func paramsUpdatedBySettings(params: HttpAfRequestParams) -> [String: Any]? {

        if params.url.contains(CustomSettings.http.url.main.value) {
            let settingsParams = CustomSettings
                .http
                .params
                .main
                .value
            return settingsParams.merge(with: params
                .params ?? [:])
        } else if params.url.contains(CustomSettings.http.url.auth.value) {
            let settingsParams = CustomSettings
                .http
                .params
                .auth
                .value
            return settingsParams.merge(with: params
                .params ?? [:])
        } else {
            return params.params
        }

    }

    private func headersUpdatedBySettings(params: HttpAfRequestParams) -> HTTPHeaders? {
        if params.url.contains(CustomSettings.http.url.main.value) {
            var settingsHeaders = CustomSettings
                                    .http
                                    .headers
                                    .main
                                    .value
                                    .asHTTPHeaders
            settingsHeaders.merge(with: params.headers)
            return settingsHeaders
        } else if params.url.contains(CustomSettings.http.url.auth.value) {
            var settingsHeaders = CustomSettings
                                    .http
                                    .headers
                                    .auth
                                    .value
                                    .asHTTPHeaders
            settingsHeaders.merge(with: params.headers)
            return settingsHeaders
        } else {
            return params.headers
        }

    }


    private func validate(withUrlRequest urlRequest: URLRequest?,
                          withResponse response: HTTPURLResponse,
                          withData data: Data?,
                          usingParams params: HttpAfRequestParams,
                          withResponseStatusHandler responseStatusHandler: HttpResponseStatusHandler? = nil) -> DataRequest.ValidationResult  {

        if let responseStatusHandler = responseStatusHandler {
            do {
                try responseStatusHandler(response.statusCode,
                                          data)
            } catch let error {
                return .failure(error)
            }
        }

        if params.validation.contains(response.statusCode) {
            return .success(())
        } else {
            
            if let data = data,
               let message = String(data: data,
                                    encoding: .utf8) {
                return .failure(CommonErrors.Custom.withHeader(message: message))
            } else {
                return .failure(CommonErrors.Http.wrongStatusCodeValidation(response.statusCode))
            }
        }

    }

    private func createRequest(withParams params: HttpAfRequestParams,
                               withResponseStatusHandler responseStatusHandler:
                               HttpResponseStatusHandler? = nil) -> DataRequest {

        var requestHeaders: HTTPHeaders = params.headers
        requestHeaders["Content-Type"] = "application/json"

        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = params.timeout
        configuration.timeoutIntervalForResource = params.timeout

        let paramsUpdatedBySettings = self.paramsUpdatedBySettings(params: params)
        let headersUpdatedBySettings = self.headersUpdatedBySettings(params: params)

        AF.sessionConfiguration.timeoutIntervalForRequest = params.timeout
        AF.sessionConfiguration.timeoutIntervalForResource = params.timeout

        let afSessionReactive = AF//Session(configuration: configuration)

        return afSessionReactive
            .request(params.url,
                     method: params.requestMethod,
                     parameters: paramsUpdatedBySettings,
                     encoding: params.paramsEncoding,
                     headers: headersUpdatedBySettings)

    }

    private func createAndValidateRequest<ResultType: Decodable>(withParams params: HttpAfRequestParams,
                               withResponseStatusHandler responseStatusHandler:
                               HttpResponseStatusHandler? = nil) -> AnyPublisher<ResultType, Error> {

        self.createRequest(withParams: params,
                           withResponseStatusHandler: responseStatusHandler)
            .validate({[weak self] (request, response, data) -> DataRequest.ValidationResult in

                guard let self = self else {
                    return .failure(CommonErrors.Instance.selfFailed)
                }

                return self.validate(withUrlRequest: request,
                                      withResponse: response,
                                      withData: data,
                                      usingParams: params,
                                      withResponseStatusHandler: responseStatusHandler)
            })
            .publishDecodable(type: ResultType.self)            
            .value()
            .mapError { afError in
                afError.asError
            }
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()

    }

    private func createAndValidateRequest(withParams params: HttpAfRequestParams,
                               withResponseStatusHandler responseStatusHandler:
                               HttpResponseStatusHandler? = nil) -> AnyPublisher<Data, Error> {

        self.createRequest(withParams: params,
                           withResponseStatusHandler: responseStatusHandler)
            .validate({[weak self] (request, response, data) -> DataRequest.ValidationResult in

                guard let self = self else {
                    return .failure(CommonErrors.Instance.selfFailed)
                }

                return self.validate(withUrlRequest: request,
                                      withResponse: response,
                                      withData: data,
                                      usingParams: params,
                                      withResponseStatusHandler: responseStatusHandler)
            })
            .publishData()
            .value()
            .mapError { afError in
                afError.asError
            }
            //.subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()

    }

    private func createAndValidateRequest(withParams params: HttpAfRequestParams,
                               withResponseStatusHandler responseStatusHandler:
                               HttpResponseStatusHandler? = nil) -> AnyPublisher<Void, Error> {

        return self.createRequest(withParams: params,
                           withResponseStatusHandler: responseStatusHandler)
            .validate({[weak self] (request, response, data) -> DataRequest.ValidationResult in

                guard let self = self else {
                    return .failure(CommonErrors.Instance.selfFailed)
                }

                return self.validate(withUrlRequest: request,
                                      withResponse: response,
                                      withData: data,
                                      usingParams: params,
                                      withResponseStatusHandler: responseStatusHandler)
            })
            .publishUnserialized()
            .value()
            .map { _ in
                return ()
            }
            .mapError({ afError in
                afError.asError
            })
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()

    }



}

extension CustomHttpAfService {

    private func createUpload(fileUrl: URL,
                               withParams params: HttpAfRequestParams,
                               withResponseStatusHandler responseStatusHandler:
                               HttpResponseStatusHandler? = nil) -> DataRequest {

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = params.timeout
        configuration.timeoutIntervalForResource = params.timeout

        let headersUpdatedBySettings = self.headersUpdatedBySettings(params: params)

        let afSessionReactive = Alamofire.Session(configuration: configuration)
        return afSessionReactive
            .upload(fileUrl,
                    to: params.url,
                    method: params.requestMethod,
                    headers: headersUpdatedBySettings)

    }

    private func createAndValidateUpload<ResultType: Decodable>(fileUrl: URL,
                                                            withParams params: HttpAfRequestParams,
                                                            withResponseStatusHandler responseStatusHandler:
                                                            HttpResponseStatusHandler? = nil) -> AnyPublisher<ResultType, Error> {

        self.createUpload(fileUrl: fileUrl,
                          withParams: params,
                          withResponseStatusHandler: responseStatusHandler)
            .validate({[weak self] (request, response, data) -> DataRequest.ValidationResult in

                guard let self = self else {
                    return .failure(CommonErrors.Instance.selfFailed)
                }

                return self.validate(withUrlRequest: request,
                                      withResponse: response,
                                      withData: data,
                                      usingParams: params,
                                      withResponseStatusHandler: responseStatusHandler)
            })
            .publishDecodable(type: ResultType.self)
            .value()
            .mapError { afError in
                afError.asError
            }
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()

    }

    private func createAndValidateUpload(fileUrl: URL,
                                                            withParams params: HttpAfRequestParams,
                                                            withResponseStatusHandler responseStatusHandler:
                                                            HttpResponseStatusHandler? = nil) -> AnyPublisher<Void, Error> {

        self.createUpload(fileUrl: fileUrl,
                          withParams: params,
                          withResponseStatusHandler: responseStatusHandler)
            .validate({[weak self] (request, response, data) -> DataRequest.ValidationResult in

                guard let self = self else {
                    return .failure(CommonErrors.Instance.selfFailed)
                }

                return self.validate(withUrlRequest: request,
                                      withResponse: response,
                                      withData: data,
                                      usingParams: params,
                                      withResponseStatusHandler: responseStatusHandler)
            })
            .publishUnserialized()
            .value()
            .map { _ in
                return ()
            }
            .mapError { afError in
                afError.asError
            }
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()

    }

    private func wrap<OutputType, Error>(_ object: AnyPublisher<OutputType, Error>) -> AnyPublisher<AnyPublisher<OutputType, Error>, Never> {
        Just(object)
            .eraseToAnyPublisher()
    }

}
