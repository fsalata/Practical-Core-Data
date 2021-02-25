import CoreData
import Foundation

public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {
  public let persistentContainer: PersistentContainer

  private let importer: InitialImporter
  
  public init() {
    let transformer = UIImageTransformer()
    ValueTransformer.setValueTransformer(transformer, forName: UIImageTransformer.name)
    
    persistentContainer = PersistentContainer(name: "Chapter9")
    
    for description in persistentContainer.persistentStoreDescriptions {
      description.shouldInferMappingModelAutomatically = false
      description.shouldMigrateStoreAutomatically = false
    }

    do {
      let migrator = CoreDataMigrator(container: persistentContainer)
      try migrator.migrateStoresIfNeeded()
    } catch {
      fatalError("Core Data store migration not possible: \(error)")
    }
    
    persistentContainer.loadPersistentStores(completionHandler: { description, error in
      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })
    
    importer = InitialImporter(container: persistentContainer)
    importer.importIfNeeded()
  }
  
  public func childViewContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.parent = persistentContainer.viewContext
    return context
  }
}
