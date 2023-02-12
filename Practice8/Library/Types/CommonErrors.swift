//
//  CustomError.swift
//  HRPoll_New
//
//  Created by Andrew on 20.12.2022.
//

import Foundation

// MARK: - CommonErrors
public class CommonErrors {

    public enum Custom: Error, CustomStringConvertible {
        case withHeader(header: String? = nil, message: String)
        case onOwner(owner: ErrorHeaderReadable, message: String)

        public var description: String {
            switch self {
                case .withHeader(let header,
                                 let message):
                let header = (header != nil && !header!.isEmpty)
                ? "\(header!): "
                : ""
                return "\(header)\(message)"

            case .onOwner(let owner,
                          let message):
                return "\(owner.errorHeader): \(message)"

            }
        }
    }

    public enum Instance: Error, CustomStringConvertible {
        case selfFailed
        public var description: String {
            return "Невалидный объект self"
        }
    }

    public enum Http: Error, CustomStringConvertible {

        case returningDataType
        case unknown
        case connection
        case emptyUrl
        case emptyParams
        case invalidUrl
        case authorization
        case serialization
        case mapping
        case emptyResponse
        case wrongResultType
        case wrongStatusCodeValidation(_ statusCode: Int)

        public var description: String {

            switch self {
                case .returningDataType:
                    return "Указанный тип данных не удовлетворяет требованиям запроса"
                case .unknown:
                    return "Неизвестная ошибка http-запроса"
                case .connection:
                    return "Ошибка http соединения"
                case .emptyUrl:
                    return "Не указан URL запроса"
                case .emptyParams:
                    return "Не указаны параметры запроса"
                case .invalidUrl:
                    return "Неверный URL запроса"
                case .authorization:
                    return "Ошибка авторизации"
                case .serialization:
                    return "Ошибка сериализации Http-response."
                case .mapping:
                    return "Ошибка маппинга данных."
                case .emptyResponse:
                    return "Ответ сервера не содержит данных."
                case .wrongResultType:
                    return "Неверный тип результата."
                case .wrongStatusCodeValidation(let statusCode):
                    return "Невалидный статус ответа сервера: \(statusCode)"
            }
        }
    }

    public enum UserDefaults: Error, CustomStringConvertible {
        case notFound(_ key: String)

        public var description: String {
            switch self {
            case .notFound(let key):
                return "Запись UserDefaults с ключом \(key) не найдена"
            }
        }
    }

    public enum CoreData: Error, CustomStringConvertible {

        case tableNotFound(tableName: String)
        case entityNotCreated
        case contextNotCreated

        public var description: String {
            switch self {
            case .tableNotFound(let tableName):
                    return "Таблица \(tableName) не найдена"
            case .entityNotCreated:
                    return "Ошибка создания объекта NSEntityDescription."
            case .contextNotCreated:
                    return "Ошибка создания объекта NSManagedObjectContext."
            }
        }

    }

    public enum Nil: Error, CustomStringConvertible {
        case isNil

        public var description: String {
            switch self {
            case .isNil:
                return "Значение не определено"
            }
        }
    }

}
