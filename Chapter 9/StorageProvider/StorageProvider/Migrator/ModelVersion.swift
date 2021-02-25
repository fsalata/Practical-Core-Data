import CoreData

/// Every CoreData model is represented by a version of the xcdatamodeld file and should have an entry in the
/// ModelVersion enum.
enum ModelVersion: String, CaseIterable {
  case v1 = "Chapter9"
  case v2 = "Chapter9 2"
  case v3 = "Chapter9 3"
  case v4 = "Chapter9 4"
  
  static var current: ModelVersion {
    return .v4
  }
  
  /// Used to obtain the next version of a model (if any). This allows migrations to be executed from one version to the next
  /// rather than jumping from a current version directly to the latest (the default CoreData behavior)
  ///
  /// - Returns: The next ModelVersion
  func next() -> ModelVersion? {
    switch self {
    case .v1: return .v2
    case .v2: return .v3
    case .v3: return .v4
    case .v4: return nil
    }
  }
  
  /// Helper to find a model version that is compatible with the supplied store metadata.
  ///
  /// - Parameter metadata: The metadata to find a model version for.
  /// - Returns: A compatible model version if one is found.
  static func compatibleVersionForStoreMetadata(_ metadata: [String: Any]) throws -> ModelVersion? {
    let bundle = Bundle(for: CoreDataMigrator.self)

    let compatibleVersion = try ModelVersion.allCases.first { modelVersion in
      let model = try NSManagedObjectModel.managedObjectModel(forResource: modelVersion.rawValue, in: bundle)
      return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }

    return compatibleVersion
  }
}
