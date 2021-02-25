import CoreData

extension NSPersistentStoreCoordinator {

  /// Removes the store for the provided store URL.
  ///
  /// - Parameter storeURL: The URL to remove the store for.
  static func destroyStore(at storeURL: URL) throws {
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
    try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
  }

  /// Replaces one store with the other.
  ///
  /// - Parameters:
  ///   - targetURL: The URL for the store that should be removed.
  ///   - sourceURL: The URL for the store that should be added.
  static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) throws {
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
    try persistentStoreCoordinator.replacePersistentStore(at: targetURL, destinationOptions: nil,
                                                          withPersistentStoreFrom: sourceURL, sourceOptions: nil,
                                                          ofType: NSSQLiteStoreType)
  }

  /// Convenience method to obtain store metadata.
  ///
  /// - Parameter storeURL: The store URL to obtain metadata for.
  /// - Returns: The store metadata.
  static func metadata(at storeURL: URL) throws -> [String: Any] {
    return try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL,
                                                                        options: nil)
  }

  /// Adds an SQL lite store to the current coordinator with the supplied options
  ///
  /// - Parameters:
  ///   - storeURL: The URL for the store that should be added.
  ///   - options: The store options that should be appliec to the persistent store.
  /// - Returns: The persistent store that was just added to the coordinator.
  func addPersistentStore(at storeURL: URL, options: [AnyHashable: Any]) throws -> NSPersistentStore {
    return try addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
  }
}
