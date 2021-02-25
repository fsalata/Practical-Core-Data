import Foundation
import CoreData
import UIKit

class V4AlbumToAlbumPolicy: NSEntityMigrationPolicy {
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
    
    
    if let sourceData = sInstance.value(forKey: "albumCover") as? Data,
       let image = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: sourceData),
       let jpeg = image.jpegData(compressionQuality: 1) {
      
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask).first!
      let path = "\(UUID().uuidString).jpeg"
      
      let url = documentsDirectory.appendingPathComponent(path)
      do {
        try jpeg.write(to: url)
        destinationAlbum.setValue(path, forKey: "albumCoverPath")
      } catch {
        print(error)
      }
    }
    
    manager.associate(sourceInstance: sInstance,
                      withDestinationInstance: destinationAlbum,
                      for: mapping)
  }
}
