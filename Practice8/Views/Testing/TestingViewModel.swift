//
//  TestingViewModel.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 15.02.2023.
//

import Foundation
import Combine

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
                                                     withParams: ["apiToken": apiToken],
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
            }
            .fromFlow()
            .sink { _ in

            } receiveValue: { (flow: (TheNewsApiSources, SemanticInfo?)) in
                flow.0.data
            }
            .store(in: &self.bag)






    }


}
