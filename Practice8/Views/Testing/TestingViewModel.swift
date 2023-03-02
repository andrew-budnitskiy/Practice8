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
    
}

extension TestingViewModel {

    func remoteDataRequest() -> AnyPublisher<TheNewsApiSources, Error> {

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

    func coreDataCacheRequest() -> AnyPublisher<[TheNewsApiSource], Error> {
        return self
            .request
            .database
            .list(fromTable: .tables.TheNewsApiSources)
            .map { items in
                return items ?? []
            }
            .eraseToAnyPublisher()
    }

    func cleanCacheRequest() -> AnyPublisher<Void, Error> {
        return self
            .request
            .database
            .delete(inTable: .tables.TheNewsApiSources)
    }

    func saveDataToCache(fromContext context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        self
            .request
            .database
            .commit_(onContext: context)
    }

    func semanticInfoRequest() -> AnyPublisher<SemanticInfo?, Error> {

        let semanticInfo: SemanticInfo? = self
            .request
            .userDefaults.value(forKey: "",
                                usingDecoder: JSONDecoder())

        return Future<SemanticInfo?, Error>.init { promise in
            promise(.success(semanticInfo))
        }
        .eraseToAnyPublisher()

    }


    func execute() {

        let cacheRequest = Publishers.CombineLatest(coreDataCacheRequest(),
                                                    semanticInfoRequest())
            .map { data, semantic in
                return (data, semantic)
            }
            .asFlow
            .connectPending(to: self)
            .eraseToAnyPublisher()

        let remoteRequest = self.remoteDataRequest()
                            .map { apiData -> (TheNewsApiSources, SemanticInfo?) in
                                return (apiData, SemanticInfo(withLastUpdate: Date()))
                            }
                            .asFlow
                            .connectPending(to: self)
                            .eraseToAnyPublisher()

        cacheRequest
            .flatMap { (a: Flow) -> AnyPublisher<Flow, Error> in
                return remoteRequest
                    .map { flow in
                        switch flow {
                        case .data(let data):
                            break
                        default:
                            break
                        }
                        return flow
                    }
                    .eraseToAnyPublisher()
            }
            .fromFlow()
            .sink { _ in

            } receiveValue: { (data: (TheNewsApiSources, SemanticInfo?)) in

            }
            .store(in: &self.bag)






    }


}
