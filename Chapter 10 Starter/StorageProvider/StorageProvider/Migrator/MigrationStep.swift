import CoreData

class MigrationStep {
  let sourceModel: NSManagedObjectModel
  let destinationModel: NSManagedObjectModel
  let mappingModel: NSMappingModel

  init(sourceVersion: ModelVersion, destinationVersion: ModelVersion) throws {
    let bundle = Bundle(for: Self.self)
    let sourceModel = try NSManagedObjectModel.managedObjectModel(forResource: sourceVersion.rawValue, in: bundle)
    let destinationModel = try NSManagedObjectModel.managedObjectModel(forResource: destinationVersion.rawValue, in: bundle)

    guard let mappingModel = MigrationStep.mappingModel(from: sourceModel, to: destinationModel, in: bundle) else {
      throw CoreDataMigrationError.mappingModelNotFound
    }

    self.sourceModel = sourceModel
    self.destinationModel = destinationModel
    self.mappingModel = mappingModel
  }

  /// Convenience method to obtain a mapping model between two versions. Returns a custom mapping model if one exists. If no
  /// custom mapping model exists, an inferred mapping model is used as a fallback.
  ///
  /// - Parameters:
  ///   - sourceModel: The source managed object model.
  ///   - destinationModel: The destination managed object model.
  /// - Returns: The mapping model if one exists.
  private static func mappingModel(from sourceModel: NSManagedObjectModel,
                                   to destinationModel: NSManagedObjectModel,
                                   in bundle: Bundle) -> NSMappingModel? {
    guard let customMapping = NSMappingModel(from: [bundle],
                                             forSourceModel: sourceModel,
                                             destinationModel: destinationModel) else {
      return try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel,
                                                      destinationModel: destinationModel)
    }

    return customMapping
  }
}
