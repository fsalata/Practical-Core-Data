import CoreData

class CoreDataStack {
  lazy var managedObjectModel: NSManagedObjectModel = {
    guard let url = Bundle.main.url(forResource: "MyModel", withExtension: "momd") else {
      fatalError("Failed to locate momd file for MyModel")
    }
    
    guard let model = NSManagedObjectModel(contentsOf: url) else {
      fatalError("Failed to load momd file for MyModel")
    }
    
    return model
  }()
  
  lazy var coordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first!
    let sqlitePath = documentsDirectory.appendingPathComponent("MyModel.sqlite")
    
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                         configurationName: nil,
                                         at: sqlitePath,
                                         options: nil)
    } catch {
      fatalError("Something went wrong while setting up the coordinator \(error)")
    }
    
    return coordinator
  }()
  
  lazy var viewContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    return context
  }()
}
