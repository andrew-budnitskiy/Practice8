//
//  CustomCoreDataService.swift
//  Locator
//
//  Created by Andrew on 15.04.2021.
//

import Foundation
import CoreData
import Combine

open class CustomCoreDataService: ErrorHeaderReadable {

    private var ground: CoreDataGround {

        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Database"
        return CoreDataGround.instance(withModelName: appName, withStoreName: appName)

    }

    public func createContext(derivedOn parent: NSManagedObjectContext? = nil,
                              onConcurrency concurrency: NSManagedObjectContextConcurrencyType =
                                .privateQueueConcurrencyType) throws -> NSManagedObjectContext? {

        return try self
            .ground
            .newManageObjectContext(derivedFrom: parent,
                                    onConcurrencyType: concurrency)

    }

    public func commit(onContext context: NSManagedObjectContext? = nil) throws {

        if (context ?? self.ground.managedObjectContext)?.hasChanges ?? false {
            try (context ?? self.ground.managedObjectContext)?.save()
        }

    }

    public func commit_(onContext context: NSManagedObjectContext? = nil) -> AnyPublisher<Void, Error> {

        return Future.init { [weak self] promise in
            do {
                guard let self = self else {
                    throw CommonErrors.Instance.selfFailed
                }
                if (context ?? self.ground.managedObjectContext)?.hasChanges ?? false {
                    try (context ?? self.ground.managedObjectContext)?.save()
                }
                promise(.success(()))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()

    }

    public func rollback(onContext context: NSManagedObjectContext? = nil) -> AnyPublisher<Void, Error> {
        return Future.init {[weak self] promise in
            guard let self = self else {
                promise(.failure(CommonErrors.Instance.selfFailed))
                return
            }
            let result: Void = self.rollback(onContext: context)
            promise(.success(result))
        }.eraseToAnyPublisher()
    }

    public func rollback(onContext context: NSManagedObjectContext? = nil) {

        if (context ?? self.ground.managedObjectContext)?.hasChanges ?? false {
            (context ?? self.ground.managedObjectContext)?.rollback()
        }

    }

    public func fetchCount(
        forTable tableName: String,
        predicate: NSPredicate? = nil,
        from: Int? = nil,
        count: Int? = nil,
        in context: NSManagedObjectContext? = nil) -> AnyPublisher<Int, Error> {

            return Future.init {[weak self] promise in
                do {
                    guard let self = self else {
                        throw CommonErrors.Instance.selfFailed
                    }

                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: tableName)
                    fetchRequest.predicate = predicate
                    fetchRequest.returnsObjectsAsFaults = false
                    if count != nil {
                        fetchRequest.fetchLimit = count!
                    }
                    if from != nil {
                        fetchRequest.fetchOffset = from!
                    }

                    let context = context ?? self.ground.managedObjectContext

                    let result = try (context?.count(for: fetchRequest) ?? 0)
                    promise(.success(result))

                } catch let error {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()

    }


    public func add<ItemInstanceType: NSManagedObject>(toTable tableName: String,
                               autoCommit: Bool = true,
                               onContext context: NSManagedObjectContext? = nil,
                               withItemHandler handler: @escaping ParametrizedActionHandler<ItemInstanceType>) -> AnyPublisher<Void, Error> {

            return Future<Void, Error>.init {[weak self] promise in
                do {
                    guard let self = self else {
                        throw CommonErrors.Instance.selfFailed
                    }
                    let result: Void = try self.add(toTable: tableName,
                                                                 autoCommit: autoCommit,
                                                                 onContext: context,
                                                                 withItemHandler: handler)
                    promise(.success((result)))
                } catch let error {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()

    }


    public func add<ItemInstanceType: NSManagedObject>(toTable tableName: String,
                               autoCommit: Bool = true,
                               onContext context: NSManagedObjectContext? = nil,
                               withItemHandler handler: @escaping ParametrizedActionHandler<ItemInstanceType>) throws {

        let entityDescription = try self.ground.entityDescription(forEntityName: tableName)
        if let newObject: ItemInstanceType = self
                                            .ground
                                            .createNewObject(forEntityDescription: entityDescription,
                                                             onContext: context) as? ItemInstanceType {
                handler(newObject)
        }

        if autoCommit {
            try self.commit(onContext: context)
        }

    }

    public func update(inTable tableName: String,
                propertiesToUpdate: [String: Any],
                autoCommit: Bool = true,
                onContext context: NSManagedObjectContext? = nil,
                withPredicate predicate: NSPredicate? = nil) -> AnyPublisher<Void, Error> {

        return Future<Void, Error>.init {[weak self] promise in
            do {
                guard let self = self else {
                    throw CommonErrors.Instance.selfFailed
                }
                let result: Void = try self.update(inTable: tableName,
                                                propertiesToUpdate: propertiesToUpdate,
                                                autoCommit: autoCommit,
                                                onContext: context, withPredicate: predicate)
                promise(.success(result))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()

    }

    public func update(inTable tableName: String,
                propertiesToUpdate: [String: Any],
                autoCommit: Bool = true,
                onContext context: NSManagedObjectContext? = nil,
                withPredicate predicate: NSPredicate? = nil) throws {

        let batchUpdateRequest = NSBatchUpdateRequest(entityName: tableName)
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate
        batchUpdateRequest.resultType = .updatedObjectsCountResultType

        let _ = try (context ?? self.ground.managedObjectContext)?.execute(batchUpdateRequest)
        if autoCommit {
            try self.commit(onContext: context)
        }

    }

    public func update<ItemInstanceType: NSManagedObject>(inTable tableName: String,
                                  autoCommit: Bool = true,
                                  onContext context: NSManagedObjectContext? = nil,
                                  withPredicate predicate: NSPredicate? = nil,
                                  withItemHandler handler: @escaping ParametrizedActionHandler<[ItemInstanceType]?>) -> AnyPublisher<Void, Error> {

        return Future<Void, Error>.init {[weak self] promise in
            do {
                guard let self = self else {
                    throw CommonErrors.Instance.selfFailed
                }

                let result: Void = try self.update(inTable: tableName,
                                                autoCommit: autoCommit,
                                                onContext: context,
                                                withPredicate: predicate,
                                                withItemHandler: handler)
                promise(.success(result))

            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()

    }

    public func update<ItemInstanceType: NSManagedObject>(inTable tableName: String,
                                  autoCommit: Bool = true,
                                  onContext context: NSManagedObjectContext? = nil,
                                  withPredicate predicate: NSPredicate? = nil,
                                  withItemHandler handler: @escaping ParametrizedActionHandler<[ItemInstanceType]?>) throws {

        let fetchRequest = NSFetchRequest<ItemInstanceType>(entityName: tableName)
        fetchRequest.predicate = predicate

        let items = try (context ?? self.ground.managedObjectContext)?.fetch(fetchRequest) ?? []
        handler(items)

        if autoCommit {
            try self.commit(onContext: context)
        }

    }

    public func delete(inTable tableName: String,
                autoCommit: Bool = true,
                onContext context: NSManagedObjectContext? = nil,
                withPredicate predicate: NSPredicate? = nil) -> AnyPublisher<Void, Error> {

        return Future<Void, Error>.init {[weak self] promise in
            do {
                guard let self = self else {
                    throw CommonErrors.Instance.selfFailed
                }
                let result: Void = try self.delete(inTable: tableName,
                                         autoCommit: autoCommit,
                                         onContext: context,
                                         withPredicate: predicate)
                promise(.success(result))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    public func delete(inTable tableName: String,
                autoCommit: Bool = true,
                onContext context: NSManagedObjectContext? = nil,
                withPredicate predicate: NSPredicate? = nil) throws {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: tableName)
        fetchRequest.predicate = predicate

        let items = try (context ?? self.ground.managedObjectContext)?.fetch(fetchRequest) ?? []
        for item in items {
            (context ?? self.ground.managedObjectContext)?.delete(item)
        }

        if autoCommit {
            try self.commit(onContext: context)
        }

    }

    public func list<ItemInstanceType: NSManagedObject>(fromTable tableName: String,
              withPredicate predicate: NSPredicate? = nil,
              onContext context: NSManagedObjectContext? = nil,
              usingSortDescriptors sortDescriptors: [NSSortDescriptor]? = []) -> AnyPublisher<[ItemInstanceType]?, Error> {

        return Future<[ItemInstanceType]?, Error>.init {[weak self] promise in

            do {
                guard let self = self else {
                    throw CommonErrors.Instance.selfFailed
                }
                let result: [ItemInstanceType]? = try self.list(fromTable: tableName,
                               withPredicate: predicate,
                               onContext: context,
                               usingSortDescriptors: sortDescriptors)
                promise(.success(result))
            } catch let error {
                promise(.failure(error))
            }

        }.eraseToAnyPublisher()

    }

    public func list<ItemInstanceType: NSManagedObject>(fromTable tableName: String,
              withPredicate predicate: NSPredicate? = nil,
              onContext context: NSManagedObjectContext? = nil,
              usingSortDescriptors sortDescriptors: [NSSortDescriptor]? = []) throws -> [ItemInstanceType]? {

        let fetchRequest = NSFetchRequest<ItemInstanceType>(entityName: tableName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        let result: [ItemInstanceType]? = try (context ?? self.ground.managedObjectContext)?.fetch(fetchRequest)
        return result

    }

    public func item<ItemInstanceType: NSManagedObject>(fromTable tableName: String,
                                                 withPredicate predicate: NSPredicate? = nil,
                                                 onContext context: NSManagedObjectContext? = nil) -> AnyPublisher<ItemInstanceType?, Error> {

        return Future<ItemInstanceType?, Error>.init {[weak self] promise in
            do {
                guard let self = self else {
                    throw CommonErrors.Instance.selfFailed
                }
                let result: ItemInstanceType?  = try self.item(fromTable: tableName,
                                                                withPredicate: predicate,
                                                                onContext: context)
                promise(.success(result))
            } catch let error {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()

    }

    public func item<ItemInstanceType: NSManagedObject>(fromTable tableName: String,
                                                 withPredicate predicate: NSPredicate? = nil,
                                                 onContext context: NSManagedObjectContext? = nil) throws -> ItemInstanceType? {

        let fetchRequest = NSFetchRequest<ItemInstanceType>(entityName: tableName)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        let result: [ItemInstanceType]? = try (context ?? self.ground.managedObjectContext)?.fetch(fetchRequest)
        return !(result?.isEmpty ?? true)
            ? result?[0]
            : nil

    }

    private init() {

    }

    private static var instanceItem: CustomCoreDataService = {
       return CustomCoreDataService.init()
    }()

    public class func instance() -> CustomCoreDataService {
        return self.instanceItem
    }

}
