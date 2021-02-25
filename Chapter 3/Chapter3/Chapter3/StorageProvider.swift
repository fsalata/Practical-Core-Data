import CoreData

class StorageProvider {

  static var standard = StorageProvider()
  let persistentContainer: NSPersistentContainer

  init() {
    ValueTransformer.setValueTransformer(UIImageTransformer(),
                                         forName: NSValueTransformerName("UIImageTransformer"))
    
    persistentContainer = NSPersistentContainer(name: "Chapter3")

    persistentContainer.loadPersistentStores(completionHandler: { description, error in
      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })

    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
  }
}
