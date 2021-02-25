enum CoreDataMigrationError: Error {
  case mappingModelNotFound
  case managedObjectModelNotFound
  case managedObjectModelNotLoaded
  case metadataNotLoaded
  case noCompatibleStoreVersionFound
}
