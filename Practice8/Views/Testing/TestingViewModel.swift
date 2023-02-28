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

    func semanticInfoRequest() -> AnyPublisher<SematicInfo?, Error> {

        let semanticInfo: SematicInfo? = self
            .request
            .userDefaults.value(forKey: "",
                                usingDecoder: JSONDecoder())


        return Future<SematicInfo?, Error>.init { promise in
            promise(.success(semanticInfo))
        }
        .eraseToAnyPublisher()

    }


}
