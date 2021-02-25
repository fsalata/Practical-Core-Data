import CoreData

public class ExampleViewModel {
  public let persistentContainer = StorageProvider().persistentContainer

  public init() {
    let didSaveNotification = NSManagedObjectContext.didChangeObjectsNotification
    NotificationCenter.default.addObserver(self, selector: #selector(didSave(_:)),
                                           name: didSaveNotification, object: persistentContainer.viewContext)
  }

  @objc public func didSave(_ notification: Notification) {
    guard let insertedObjects = notification.insertedObjects else {
      return
    }

    let objectIDs = insertedObjects.map(\.objectID)

    for id in objectIDs {
      if let object = try? persistentContainer.viewContext.existingObject(with: id) {
        // use object in viewContext
      }
    }
  }
}
