//
//  TestingViewModel.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 15.02.2023.
//

import Foundation
import Combine
import CoreData

class TestingViewModel: PracticeViewModel {

    private static let emptyUpdateInfo = "Загрузка данных не производилась"

    @Published var list: [TheNewsApiSource] = []
    @Published var lastUpdate: String = emptyUpdateInfo

}

extension TestingViewModel {

    func remoteDataRequest(usingContext context: NSManagedObjectContext) -> AnyPublisher<TheNewsApiSources, Error> {

        TheNewsApiSource.Context = context
        let apiToken: String = "wVTpnmkmnAQudIaFoRgqZhyNcCMlbsA6Fd8fDR6i"
        let url = "https://api.thenewsapi.com/v1/news/sources"
        let result: AnyPublisher<TheNewsApiSources, Error> = self
            .request
            .http
            .execute(withParams: HttpAfRequestParams(withUrl: url,
                                                     withParams: ["api_token": apiToken],
                                                     withRequestMethod: .get))
        return result
    }
}

extension TestingViewModel {

    private func coreDataCacheRequest() -> AnyPublisher<[TheNewsApiSource], Error> {
        return self
            .request
            .database
            .list(fromTable: .tables.TheNewsApiSources)
            .map { items in
                return items ?? []
            }
            .eraseToAnyPublisher()
    }

    private func cleanCacheRequest() -> AnyPublisher<Void, Error> {
        return self
            .request
            .database
            .delete(inTable: .tables.TheNewsApiSources)
    }

    private func saveDataToCache(fromContext context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        self
            .request
            .database
            .commit_(onContext: context)
    }

    private func semanticInfoRequest() -> AnyPublisher<SemanticInfo?, Error> {

        let semanticInfo: SemanticInfo? = self
            .request
            .userDefaults.value(forKey: "",
                                usingDecoder: JSONDecoder())

        return Future<SemanticInfo?, Error>.init { promise in
            promise(.success(semanticInfo))
        }
        .eraseToAnyPublisher()

    }

    private func lastUpdateInfo(from semantic: SemanticInfo?) -> String {

        guard let lastUpdate = semantic?.lastUpdate else {
            return Self.emptyUpdateInfo
        }

        let dateValue = lastUpdate.toString(withFormat: "dd.MM.yyyy HH:mm")
        return "Последнее обновление в \(dateValue)"

    }

}

extension TestingViewModel {

    func execute() {

        let cacheRequest = Publishers.CombineLatest(coreDataCacheRequest(),
                                          semanticInfoRequest())
            .map { data -> ([TheNewsApiSource], SemanticInfo?) in
                self.list = data.0
                return data
            }
            .eraseToAnyPublisher()

        let remoteRequest: (NSManagedObjectContext) -> AnyPublisher<([TheNewsApiSource], SemanticInfo?), Error> =  {[weak self] context in

            guard let self = self else {
                return Empty<([TheNewsApiSource], SemanticInfo?), Error>().eraseToAnyPublisher()
            }

            return self.remoteDataRequest(usingContext: context)
                            .map { apiData -> ([TheNewsApiSource], SemanticInfo?) in
                                return (apiData.data, SemanticInfo(withLastUpdate: Date()))
                            }
                            .eraseToAnyPublisher()
        }
//        let context = try! CommonFunctions.CoreData.Ground.newManageObjectContext()
//        cacheRequest
//            .flatMap { _ in
//                remoteRequest(context)
//            }
//            .flatMap({ _ in
//                return self.cleanCacheRequest()
//            })
//            .flatMap({ _ in
//                return self.saveDataToCache(fromContext: context)
//            })
//
//            .asFlow
//            .connectPending(to: self)
//            .connectError(to: self,
//                          collecting: &self.bag)
//            .sink { completion in
//                print(completion)
//            } receiveValue: {[weak self] /*(data: ([TheNewsApiSource], SemanticInfo?))*/ flow in
////                self?.lastUpdate = self?.lastUpdateInfo(from: data.1) ?? Self.emptyUpdateInfo
////                self?.list = data.0.data
//
//            }
//
//            .store(in: &self.bag)

        cacheRequest
            .flatMap { (data: ([TheNewsApiSource], SemanticInfo?)) -> AnyPublisher<([TheNewsApiSource], SemanticInfo?), Error> in
                let context = try! CommonFunctions.CoreData.Ground.newManageObjectContext()
                return remoteRequest(context)
                    .flatMap { [weak self] d -> AnyPublisher<Void, Error> in
                        guard let self = self else {
                            return Empty<Void, Error>().eraseToAnyPublisher()
                        }
                        return self.cleanCacheRequest()
                    }
                    .flatMap { [weak self] q -> AnyPublisher<Void, Error> in
                        guard let self = self else {
                            return Empty<Void, Error>().eraseToAnyPublisher()
                        }
                        return self.saveDataToCache(fromContext: context)
                    }
                    .map({ _ in
                        return data
                    })
                    .eraseToAnyPublisher()
            }
            .asFlow
            .connectPending(to: self)
            .connectError(to: self,
                          collecting: &self.bag)
//            .fromFlow()
            .sink { completion in
                print(completion)
            } receiveValue: {[weak self] flow in

                switch flow {
                case .data(let data):
                    if let data = data as? ([TheNewsApiSource], SemanticInfo?) {
                        self?.list = data.0
                    }
                default:
                    break
                }


                if let data: ([TheNewsApiSource], SemanticInfo?) = flow.data() {
                    self?.list = data.0
                }
            }

            .store(in: &self.bag)

    }

}
