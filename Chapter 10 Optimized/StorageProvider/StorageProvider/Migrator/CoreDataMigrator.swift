import CoreData

class CoreDataMigrator {
  let container: NSPersistentContainer
  
  init(container: NSPersistentContainer) {
    self.container = container
  }
  
  /// Checks whether any store descriptions need migration, and performs these migrations as needed
  /// Automatically migrates all descriptions that have their `shouldMigrateStoreAutomatically`
  /// property set to false.
  func migrateStoresIfNeeded(to version: ModelVersion = .current) throws {
    for description in container.persistentStoreDescriptions
      where description.shouldMigrateStoreAutomatically == false {
      
      guard let storeURL = description.url else {
        print("Cannot migrate a non-file based store description")
        continue
      }

      try migrateStore(at: storeURL, to: version)
    }
  }
  
  /// Migrates the store at the provided URL to the provided model version, performing the migration one step at a time.
  /// - Parameters:
  ///   - storeURL: The source URL for the store
  ///   - to: The target model version
  private func migrateStore(at storeURL: URL, to version: ModelVersion) throws {
    guard try requiresMigration(at: storeURL, toVersion: version) else {
      return
    }

    try forceWALCheckpointingForStore(at: storeURL)

    var currentURL = storeURL

    for step in try migrationStepsForStore(storeURL, toVersion: version) {
      let migratedStoreURL = try executeMigrationStep(step, on: currentURL)

      if currentURL != storeURL {
        try NSPersistentStoreCoordinator.destroyStore(at: currentURL)
      }

      currentURL = migratedStoreURL
    }
    
    try NSPersistentStoreCoordinator.replaceStore(at: storeURL, withStoreAt: currentURL)

    if currentURL != storeURL {
      try NSPersistentStoreCoordinator.destroyStore(at: currentURL)
    }
  }

  /// Checks whether the target version and the model version for the supplied store match. If they don't the store requires
  /// migration.
  ///
  /// - Parameters:
  ///   - storeURL: A store URL to compare.
  ///   - version: The version that the supplied store URL should be compared to.
  /// - Returns: True if the store URL and target version are not compatible.
  private func requiresMigration(at storeURL: URL, toVersion version: ModelVersion) throws -> Bool {
    guard FileManager.default.fileExists(atPath: storeURL.path) else {
      return false
    }

    let metadata = try NSPersistentStoreCoordinator.metadata(at: storeURL)
    return try ModelVersion.compatibleVersionForStoreMetadata(metadata) != version
  }
  
  /// Triggers a WAL checkpoint. This will write the sqlite wal file to the underlying strore to avoid
  /// having any lingering updates in the .wal file.
  /// - Parameter storeURL: The store to force a checkpoint for
  private func forceWALCheckpointingForStore(at storeURL: URL) throws {
    let bundle = Bundle(for: Self.self)
    let metadata = try NSPersistentStoreCoordinator.metadata(at: storeURL)

    guard let currentModel = NSManagedObjectModel.mergedModel(from: [bundle], forStoreMetadata: metadata) else {
        return
    }

    do {
      let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: currentModel)

      let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
      let store = try persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
      try persistentStoreCoordinator.remove(store)
    }
    catch {
      fatalError("failed to force WAL checkpointing, error: \(error)")
    }
  }
  
  /// Finds the required steps to migrate from a given store URL to a model version.
  ///
  /// - Parameters:
  ///   - storeURL: The store URL to migrate from.
  ///   - version: The model version to migrate to.
  /// - Returns: The steps needed to migrate from one version to the next.
  private func migrationStepsForStore(_ storeURL: URL, toVersion version: ModelVersion) throws -> [MigrationStep] {
    let metadata = try NSPersistentStoreCoordinator.metadata(at: storeURL)

    guard let sourceVersion = try ModelVersion.compatibleVersionForStoreMetadata(metadata) else {
      throw CoreDataMigrationError.noCompatibleStoreVersionFound
    }

    return try migrationSteps(from: sourceVersion, to: version)
  }
  
  /// Walks the model version list and creates migration steps until a migration step exists for every step between the
  /// source and destination version.
  ///
  /// - Parameters:
  ///   - sourceVersion: The version to start the migration from.
  ///   - destinationVersion: The version to migrate to.
  /// - Returns: An array of migration steps that need to be performed.
  private func migrationSteps(from sourceVersion: ModelVersion,
                              to destinationVersion: ModelVersion) throws -> [MigrationStep] {

    var currentVersion = sourceVersion
    var steps = [MigrationStep]()

    while currentVersion != destinationVersion, let nextVersion = currentVersion.next() {
      let step = try MigrationStep(sourceVersion: currentVersion, destinationVersion: nextVersion)
      steps.append(step)
      currentVersion = nextVersion
    }

    return steps
  }
  
  /// Performs the supplied migration step on the source URL. The migrated store is written to a new URL.
  /// This URL is returned to the caller for further processing.
  /// - Parameters:
  ///   - step: The migration step to perform
  ///   - source: The source store
  /// - Returns: The location of the migrated store
  private func executeMigrationStep(_ step: MigrationStep, on source: URL) throws -> URL {
    let manager = NSMigrationManager(sourceModel: step.sourceModel,
                                     destinationModel: step.destinationModel)

    let destination = URL(fileURLWithPath: NSTemporaryDirectory(),
                             isDirectory: true).appendingPathComponent(UUID().uuidString)

    try manager.migrateStore(from: source, sourceType: NSSQLiteStoreType, options: nil, with: step.mappingModel,
                             toDestinationURL: destination, destinationType: NSSQLiteStoreType,
                             destinationOptions: nil)
    
    return destination
  }
}
