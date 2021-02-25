import CoreData

extension NSManagedObjectModel {

  /// Used to find a managed object model based on a model version name.
  ///
  /// - Parameter resource: The model version name to find the model for.
  /// - Returns: The managed object model.
  static func managedObjectModel(forResource resource: String, in bundle: Bundle) throws -> NSManagedObjectModel {
    let subdirectory = "Chapter9.momd"

    var omoURL: URL?
    if #available(iOS 11, *) {
      omoURL = bundle.url(forResource: resource, withExtension: "omo", subdirectory: subdirectory)
    }
    let momURL = bundle.url(forResource: resource, withExtension: "mom", subdirectory: subdirectory)

    guard let url = omoURL ?? momURL else {
      throw CoreDataMigrationError.managedObjectModelNotFound
    }

    guard let model = NSManagedObjectModel(contentsOf: url) else {
      throw CoreDataMigrationError.managedObjectModelNotLoaded
    }

    return model
  }
}
