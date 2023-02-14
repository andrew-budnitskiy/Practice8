//
//  CoerDataGround.swift
//  HRMobile
//
//  Created by Andrey Budnitskiy on 01.12.2019.
//  Copyright © 2019 Andrey Budnitskiy. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataGround: ErrorHeaderReadable {
    
    private static var modelName: String = ""
    private static var storeName: String = ""

    private init() {}
    
    private static var value: CoreDataGround = {
          return CoreDataGround.init()
    }()
      
    open class func instance(withModelName modelName: String, withStoreName storeName: String) -> CoreDataGround {
          
        self.modelName = modelName
        self.storeName = storeName
        
        return self.value
        
    }
    
    private lazy var applicationDocumentsDirectory: URL? = {
      
      let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return urls.last
      
    }()

    private lazy var managedObjectModel: NSManagedObjectModel? = {

        if let modelUrls = Bundle.main.urls(forResourcesWithExtension: "momd", subdirectory: nil),
           !modelUrls.isEmpty {
          return NSManagedObjectModel(contentsOf: modelUrls[0])!
      } else {
          return nil
      }
    }()

    private lazy var storeCoordinator: NSPersistentStoreCoordinator? = {
      
      if let objectModel = self.managedObjectModel,
        let storeUrl = self.applicationDocumentsDirectory?.appendingPathComponent("\(CoreDataGround.self.storeName).sqlite") {
          
          var coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
          
          if let _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil) {
              return coordinator
          } else {
              return nil
          }
              
      } else {
          return nil
      }
      
    }()

    open lazy var managedObjectContext: NSManagedObjectContext? = {
      
      let result: NSManagedObjectContext?
      objc_sync_enter(self)
      result = self.storeCoordinator != nil
        ? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
          : nil
      
      result?.persistentStoreCoordinator = self.storeCoordinator
      result?.mergePolicy = NSOverwriteMergePolicy
        
      objc_sync_exit(self)
      return result
      
    }()
    
    open func validEntityName(tableName: String) throws -> String {
        
        guard !((self.managedObjectModel?.entitiesByName.keys.compactMap({ (key) -> String? in
            return  key == tableName ? key : nil
        })) ?? [String]()).isEmpty else {
            throw CommonErrors.CoreData.tableNotFound(tableName: tableName)
        }
        
        return tableName
        
    }
    
    open func entityDescription(forEntityName name: String) throws -> NSEntityDescription {
        
        let validEntityName = try self.validEntityName(tableName: name)
        
        if let context = self.managedObjectContext {
            
            if let result = NSEntityDescription.entity(forEntityName: validEntityName, in: context) {
                return result
            } else {
                throw CommonErrors.CoreData.entityNotCreated
            }
           
        } else {
            throw CommonErrors.CoreData.contextNotCreated
        }
        
        
    }
    
    open func createNewObject(forEntityDescription entityDescription: NSEntityDescription,
                         onContext context: NSManagedObjectContext? = nil) -> NSManagedObject {
        
        return NSManagedObject(entity: entityDescription,
                               insertInto: context ?? self.managedObjectContext)
        
    }

    open func newManageObjectContext(derivedFrom parent: NSManagedObjectContext? = nil,
                                onConcurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType) throws -> NSManagedObjectContext {
        
        if self.storeCoordinator != nil {
            
            let result = NSManagedObjectContext.init(concurrencyType: concurrencyType)
            result.parent = parent ?? self.managedObjectContext
            
//            result.persistentStoreCoordinator = self.storeCoordinator
            result.mergePolicy = NSOverwriteMergePolicy
            
            return result
            
        } else {
            throw CommonErrors.CoreData.contextNotCreated
        }
        
    }
    
}
