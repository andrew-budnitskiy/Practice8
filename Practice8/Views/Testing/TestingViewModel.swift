//
//  TestingViewModel.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 15.02.2023.
//

import Foundation
import Combine
import CoreData
// ViewModel основного экрана
class TestingViewModel: PracticeViewModel {

    private static let emptyUpdateInfo = "Загрузка данных не производилась"
    private let lastUpdateInfoKey = "lastUpdate"

    // список данных таблицы
    @Published var list: [TheNewsApiSource] = []
    // инфо о последенм обнолвении
    @Published var lastUpdate: String = emptyUpdateInfo

}

extension TestingViewModel {

    // функция запроса данных в АПИ
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

    // функция запроса данных в кэше, организованном в coreData
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

    // функция очистки кэша в coreData
    private func cleanCacheRequest() -> AnyPublisher<Void, Error> {
        return self
            .request
            .database
            .delete(inTable: .tables.TheNewsApiSources)
    }

    private func saveLastUpdateInfo() {
        self.request.userDefaults.setValue(SemanticInfo(withLastUpdate: Date()),
                                           forKey: self.lastUpdateInfoKey)
        let semanticInfo: SemanticInfo? = self.request.userDefaults.value(forKey: self.lastUpdateInfoKey)
        self.lastUpdate = self.lastUpdateInfo(from: semanticInfo)
    }

    // функция сохранения данных в кэше в coreData и информации о последнем обновлении в UserDefaults
    private func saveDataToCache(fromContext context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        self.saveLastUpdateInfo()
        return self
            .request
            .database
            .commit_(onContext: context)
            .flatMap { [weak self] _ in
                return self?
                    .request
                    .database
                    .commit_() ?? Empty<Void, Error>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

    }

    // запрос данных о последнем обновлении в UserDefaults
    private func semanticInfoRequest() -> AnyPublisher<SemanticInfo?, Error> {

        let semanticInfo: SemanticInfo? = self
            .request
            .userDefaults.value(forKey: self.lastUpdateInfoKey,
                                usingDecoder: JSONDecoder())

        return Future<SemanticInfo?, Error>.init { promise in
            promise(.success(semanticInfo))
        }
        .eraseToAnyPublisher()

    }

    //формирование строки о последнем обновлении
    private func lastUpdateInfo(from semantic: SemanticInfo?) -> String {

        guard let lastUpdate = semantic?.lastUpdate else {
            return Self.emptyUpdateInfo
        }

        let dateValue = lastUpdate.toString(withFormat: "dd.MM.yyyy HH:mm")
        return "Последняя загрузка данных в \(dateValue)"

    }

    // формирование данных кэша: coreData + userDefaults и вывод его в Published-переменные
    private var cacheRequest: AnyPublisher<([TheNewsApiSource], SemanticInfo?), Error> {

        Publishers.Zip(coreDataCacheRequest(),
                       semanticInfoRequest())
            .eraseToAnyPublisher()

    }

    func executeCacheRequest() {

        self
            .cacheRequest
            .sink(receiveCompletion: { completion in

            }, receiveValue: { [weak self] data in
                self?.list = data.0
                self?.lastUpdate = self?.lastUpdateInfo(from: data.1) ?? Self.emptyUpdateInfo
            })
            .store(in: &self.bag)

    }

}

extension TestingViewModel {

    // Функция основного запроса данных
    func execute() {

        // запрос АПИ
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

        // сначала запрашиваем кэш и отображаем его
        self.cacheRequest
            .flatMap { (data: ([TheNewsApiSource], SemanticInfo?)) -> AnyPublisher<([TheNewsApiSource], SemanticInfo?), Error> in
                // затем создаем контекст
                let context = try! CommonFunctions.CoreData.Ground.newManageObjectContext()
                // и в нем формируем объекты NSManagedObject получаемые при декодировании результатов запроса
                // см. тип TheNewsDataSource
                return remoteRequest(context)
                    .flatMap { [weak self] requestResult -> AnyPublisher<([TheNewsApiSource], SemanticInfo?), Error> in
                        guard let self = self else {
                            return Empty<([TheNewsApiSource], SemanticInfo?), Error>().eraseToAnyPublisher()
                        }
                        // очищаем кэш CoreData
                        return self.cleanCacheRequest()
                            .flatMap({ _ in
                                self.saveDataToCache(fromContext: context)
                            })
                            .map { _ in
                                return requestResult
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .catch({[weak self] error -> AnyPublisher<([TheNewsApiSource], SemanticInfo?), Error> in

                guard let self = self else {
                    return Empty<([TheNewsApiSource], SemanticInfo?), Error>().eraseToAnyPublisher()
                }
                //при ошибке возвращаем данные кэша
                return self.cacheRequest
            })
        // преобразуем в служебный тип для удобства управления progressView
            .asFlow
            .connectPending(to: self)
            .connectError(to: self,
                          collecting: &self.bag)
            .sink { completion in
                print(completion)
            } receiveValue: {[weak self] flow in

                switch flow {
                case .data(let data):
                    //результат запроса выводим в Published
                    if let data = data as? ([TheNewsApiSource], SemanticInfo?) {
                        self?.list = data.0
                    }
                default:
                    self?.list = []
                }

            }
            .store(in: &self.bag)

    }

}
