import CoreData

// I'm using a subclass so the persistent container will look for the data model in the framework bundle rather than the app bundle
public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {

  public let persistentContainer: PersistentContainer

  public init() {
    persistentContainer = PersistentContainer(name: "Chapter5")

    persistentContainer.loadPersistentStores(completionHandler: { description, error in

      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })

    try? persistentContainer.viewContext.setQueryGenerationFrom(.current)
  }
}

