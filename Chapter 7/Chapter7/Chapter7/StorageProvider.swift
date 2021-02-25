import CoreData

public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {
  public let persistentContainer: PersistentContainer

  public init() {
    persistentContainer = PersistentContainer(name: "Chapter7")

    persistentContainer.loadPersistentStores(completionHandler: { description, error in

      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })

    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
  }
}
