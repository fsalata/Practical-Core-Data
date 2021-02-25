import CoreData

public extension Dictionary where Key == AnyHashable {
  func value<T>(for key: NSManagedObjectContext.NotificationKey) -> T? {
    return self[key.rawValue] as? T
  }
}

public extension Notification {
  var insertedObjects: Set<NSManagedObject>? {
    return userInfo?.value(for: .insertedObjects)
  }

  var updatedObjects: Set<NSManagedObject>? {
    return userInfo?.value(for: .updatedObjects)
  }

  var insertedObjectIDs: Set<NSManagedObjectID>? {
    return userInfo?.value(for: .insertedObjectIDs)
  }
}
