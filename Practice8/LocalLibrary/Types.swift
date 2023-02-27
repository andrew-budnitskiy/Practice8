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
        self.locale = try container.decode(String.self, forKey: .locale)

        let categories = try container.decode([String].self, forKey: .categories)
        self.categories = categories.joined(separator: ", ")

    }

}
