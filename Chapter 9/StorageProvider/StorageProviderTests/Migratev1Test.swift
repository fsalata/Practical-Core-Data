import XCTest
import CoreData
@testable import StorageProvider

class Migratev1Test: MigrationTest {
  func testv1Tov2Migration() throws {
    let storeURL = try prepareStore(using: "version1")
    let mom = try NSManagedObjectModel.managedObjectModel(forResource: ModelVersion.v2.rawValue,
                                                          in: Bundle(for: StorageProvider.self))
    
    let container = PersistentContainer(name: "Chapter9", managedObjectModel: mom)
    container.persistentStoreDescriptions.first!.url = storeURL
    container.persistentStoreDescriptions.first!.shouldMigrateStoreAutomatically = false
    
    let migrator = CoreDataMigrator(container: container)
    try migrator.migrateStoresIfNeeded(to: .v2)
    
    container.loadPersistentStores(completionHandler: { _, error in
      XCTAssertNil(error)
    })
    
    let request = NSFetchRequest<NSManagedObject>(entityName: "Album")
    request.predicate = NSPredicate(format: "artist == %@", "Architects")
    let albums = try container.viewContext.fetch(request)
    
    XCTAssert(albums.count == 1)
    
    let album = Albumv2(artist: "Architects", title: "Holy Hell",
                        genre: "metalcore", listeningNotes: "awesome stuff",
                        releaseDate: Date(timeIntervalSince1970: 1608664864),
                        albumCover: nil)
    
    try validateAlbumv2(albums.first!, using: album)
  }
  
  func testv1ToCurrentMigration() throws {
    let storeURL = try prepareStore(using: "version1")
    let container = PersistentContainer(name: "Chapter9")
    container.persistentStoreDescriptions.first!.url = storeURL
    container.persistentStoreDescriptions.first!.shouldMigrateStoreAutomatically = false
    
    let migrator = CoreDataMigrator(container: container)
    try migrator.migrateStoresIfNeeded(to: .current)
  }
}
