import CoreData

// I'm using a subclass so the persistent container will look for the data model in the framework bundle rather than the app bundle
public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {

  static var managedObjectModel: NSManagedObjectModel = {
    let bundle = Bundle(for: StorageProvider.self)

    guard let url = bundle.url(forResource: "Chapter11", withExtension: "momd") else {
      fatalError("Failed to locate momd file for Chapter11")
    }

    guard let model = NSManagedObjectModel(contentsOf: url) else {
      fatalError("Failed to load momd file for Chapter11")
    }

    return model
  }()

  public let persistentContainer: PersistentContainer

  public init(storeType: StoreType = .persisted) {
    persistentContainer = PersistentContainer(name: "Chapter11", managedObjectModel: Self.managedObjectModel)

    if storeType == .inMemory {
      persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }

    persistentContainer.loadPersistentStores(completionHandler: { description, error in

      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })
  }
}

public enum StoreType {
  case inMemory, persisted
}
