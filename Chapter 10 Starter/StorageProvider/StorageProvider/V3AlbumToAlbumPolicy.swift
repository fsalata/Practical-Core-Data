import CoreData

class V3AlbumToAlbumPolicy: NSEntityMigrationPolicy {
  var artists = [String: NSManagedObject]()
  
  override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
    let destinationAlbum = NSEntityDescription.insertNewObject(forEntityName: "Album",
                                                               into: manager.destinationContext)
    
    let destinationKeys = destinationAlbum.entity.attributesByName.keys
    
    for key in destinationKeys {
      guard sInstance.entity.attributesByName.keys.contains(key) else {
        continue
      }

      if let value = sInstance.value(forKey: key) {
        destinationAlbum.setValue(value, forKey: key)
      }
    }
    
    guard let artistName = sInstance.value(forKey: "artist") as? String else {
      return
    }

    if let artist = artists[artistName] {
      destinationAlbum.setValue(artist, forKey: "artist")
    } else {
      let artist = NSEntityDescription.insertNewObject(forEntityName: "Artist",
                                                       into: manager.destinationContext)
      
      artist.setValue(artistName, forKey: "name")
      artists[artistName] = artist
      destinationAlbum.setValue(artist, forKey: "artist")
    }
    
    manager.associate(sourceInstance: sInstance,
                      withDestinationInstance: destinationAlbum,
                      for: mapping)
  }
}
