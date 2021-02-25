import CoreData

// I'm using a subclass so the persistent container will look for the data model in the framework bundle rather than the app bundle
public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {
  
  public let persistentContainer: PersistentContainer
  private let historyTracker: PersistentHistoryTracker
  
  private var oldStoreURL: URL {
    let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                              in: .userDomainMask).first!
    return appSupport.appendingPathComponent("Chapter6.sqlite")
  }
  
  private var sharedStoreURL: URL {
    let id = "group.com.donnywals.practicalCoreData"
    let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
    return groupContainer.appendingPathComponent("Chapter6.sqlite")
  }
  
  public init(_ actor: StorageActor) {
    persistentContainer = PersistentContainer(name: "Chapter6")
    historyTracker = PersistentHistoryTracker(persistentContainer: persistentContainer, actor: actor)
    
    if FileManager.default.fileExists(atPath: sharedStoreURL.path) {
      persistentContainer.persistentStoreDescriptions.first!.url = sharedStoreURL
    }

    persistentContainer.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    persistentContainer.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    
    persistentContainer.loadPersistentStores(completionHandler: { description, error in
      
      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })
    
    migrateStore(for: persistentContainer)
    persistentContainer.viewContext.name = "viewContext"
  }
  
  func migrateStore(for container: NSPersistentContainer) {
    guard !FileManager.default.fileExists(atPath: sharedStoreURL.path) else {
      return
    }
    
    let coordinator = container.persistentStoreCoordinator
    
    guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else {
      print("Couldn't find the old store file")
      return
    }
    
    do {
      try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL,
                                             options: nil,
                                             withType: NSSQLiteStoreType)
      
      try FileManager.default.removeItem(at: oldStoreURL)
    } catch {
      print(error)
    }
  }
}
