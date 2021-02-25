//
//  StorageProvider.swift
//  StorageProvider
//
//  Created by Donny Wals on 06/12/2020.
//

import Foundation
import CoreData

public class PersistentContainer: NSPersistentCloudKitContainer {}

public class StorageProvider {
  public let persistentContainer: PersistentContainer

  public init() {
    persistentContainer = PersistentContainer(name: "Chapter8")

    let defaultSqliteLocation = PersistentContainer.defaultDirectoryURL()

    let localStoreURL = defaultSqliteLocation.appendingPathComponent("Local.sqlite")
    let localDescription = NSPersistentStoreDescription(url: localStoreURL)
    localDescription.configuration = "Local"

    let syncedStoreURL = defaultSqliteLocation.appendingPathComponent("Synced.sqlite")
    let synchronizedDescription = NSPersistentStoreDescription(url: syncedStoreURL)
    synchronizedDescription.configuration = "Synchronized"
    synchronizedDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.practicalcoredata.chapter8")
    synchronizedDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    synchronizedDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

//    let publicStoreURL = defaultSqliteLocation.appendingPathComponent("Public.sqlite")
//    let publicDescription = NSPersistentStoreDescription(url: publicStoreURL)
//    publicDescription.configuration = "Public"
//
//    let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.practicalcoredata.chapter8")
//    options.databaseScope = .public
//
//    publicDescription.cloudKitContainerOptions = options
//    publicDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//    publicDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    persistentContainer.persistentStoreDescriptions = [localDescription, synchronizedDescription]

    persistentContainer.loadPersistentStores(completionHandler: { description, error in

      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })
    
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

  }
}

extension HouseHoldTask {
  static var currentEntityVersion = 1
  static var versionPredicate = NSPredicate(format: "%K <= %d",
                                            #keyPath(HouseHoldTask.version),
                                            currentEntityVersion)
}

extension TaskCompletion {
  static var currentEntityVersion = 1
  static var versionPredicate = NSPredicate(format: "%K <= %d",
                                            #keyPath(TaskCompletion.version),
                                            currentEntityVersion)
}

extension StorageProvider {
  func containsNewerEntities() -> Bool {
    let context = persistentContainer.viewContext

    let tasksRequest: NSFetchRequest<HouseHoldTask> = HouseHoldTask.fetchRequest()
    tasksRequest.predicate = NSPredicate(format: "%K > %d",
                                         #keyPath(TaskCompletion.version),
                                         HouseHoldTask.currentEntityVersion)
    if let count = try? context.count(for: tasksRequest), count > 0 {
      return true
    }

    let completionsRequest: NSFetchRequest<TaskCompletion> = TaskCompletion.fetchRequest()
    completionsRequest.predicate = NSPredicate(format: "%K > %d",
                                               #keyPath(TaskCompletion.version),
                                               HouseHoldTask.currentEntityVersion)
    if let count = try? context.count(for: completionsRequest), count > 0 {
      return true
    }

    return false
  }
}
