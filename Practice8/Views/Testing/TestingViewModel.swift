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
            .map { data, semantic in
                return (data, semantic)
            }
            .eraseToAnyPublisher()

        let remoteRequest = self.remoteDataRequest()
                            .map { apiData -> (TheNewsApiSources, SemanticInfo?) in
                                return (apiData, SemanticInfo(withLastUpdate: Date()))
                            }
                            .eraseToAnyPublisher()

        cacheRequest
            .flatMap { _ in
                remoteRequest
            }
            .asFlow
            .connectPending(to: self)
            .connectError(to: self,
                          collecting: &self.bag)
            .fromFlow()
            .sink { _ in

            } receiveValue: {[weak self] (data: (TheNewsApiSources, SemanticInfo?)) in
                self?.lastUpdate = self?.lastUpdateInfo(from: data.1) ?? Self.emptyUpdateInfo
                self?.list = data.0.data
            }
            .store(in: &self.bag)

    }

}
