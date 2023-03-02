//
//  Types.swift
//  Practice8
//
//  Created by Andrey Budnitskiy on 20.02.2023.
//

import Foundation
import CoreData

class TheNewsApiSource: NSManagedObject, Decodable {

    static var Context: NSManagedObjectContext? = CommonFunctions.CoreData.Ground.managedObjectContext

    public var id = UUID()

    private enum CodingKeys: String, CodingKey {
        case sourceId = "source_id"
        case domain
        case language
        case locale
        case categories
    }

    required convenience public init(from decoder: Decoder) throws {

        guard let context = Self.Context else {
            throw CommonErrors.CoreData.contextNotCreated
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.sourceId = try container.decode(String.self, forKey: .sourceId)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.language = try container.decode(String.self, forKey: .language)
        self.locale = try container.decodeIfPresent(String.self, forKey: .locale)

        let categories = try container.decode([String].self, forKey: .categories)
        self.categories = categories.joined(separator: ", ")

    }

}

class TheNewsApiSources: Decodable {

    let data: [TheNewsApiSource]

    private enum CodingKeys: CodingKey {
        case data
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([TheNewsApiSource].self, forKey: .data)
    }

}

extension String {

    class tables {
        static var TheNewsApiSources: String {
            "TheNewsApiSources"
        }
    }

}

struct SemanticInfo: Codable {

    let lastUpdate: Date?

    private enum CodingKeys: CodingKey {
        case lastUpdate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lastUpdate = try container.decodeIfPresent(Date.self, forKey: .lastUpdate)
    }

    init(withLastUpdate lastUpdate: Date?) {
        self.lastUpdate = lastUpdate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.lastUpdate, forKey: .lastUpdate)
    }

}
