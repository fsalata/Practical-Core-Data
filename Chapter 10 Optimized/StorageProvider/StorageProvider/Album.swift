import CoreData
import UIKit
import Foundation

public class Album: NSManagedObject, Identifiable {
  public static var byArtistAndNameRequest: NSFetchRequest<Album> {
    let request: NSFetchRequest<Album> = Album.fetchRequest()
    
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \Album.artist.name, ascending: true),
      NSSortDescriptor(keyPath: \Album.title, ascending: true)
    ]

    request.fetchBatchSize = 15
    request.relationshipKeyPathsForPrefetching = [
      #keyPath(Album.listeningSessions),
      #keyPath(Album.artist)
    ]
    
    return request
  }
  
  public static func fetchRequest() -> NSFetchRequest<Album> {
    return NSFetchRequest<Album>(entityName: "Album")
  }
  
  @NSManaged public var genre: String
  @NSManaged public var releaseDate: Date
  @NSManaged public var title: String
  public var albumCover: UIImage? {
    guard let path = albumCoverPath else {
      return nil
    }

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first!
    let url = documentsDirectory.appendingPathComponent(path)
    guard let data = try? Data(contentsOf: url) else {
      return nil
    }

    return UIImage(data: data)
  }
  
  @NSManaged public var albumCoverPath: String?
  @NSManaged public var artist: Artist
  @NSManaged public var listeningSessions: Set<ListeningSession>
  
  public var sortedSessions: Array<ListeningSession> {
    return Array(listeningSessions).sorted { lhs, rhs in
      return rhs.date ?? Date() > lhs.date ?? Date()
    }
  }
  
  override public func awakeFromInsert() {
    super.awakeFromInsert()
    
    releaseDate = Date()
  }
  
  public func setAlbumCover(_ image: UIImage) {
    guard let jpeg = image.jpegData(compressionQuality: 1) else {
      return
    }
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first!
    
    if let oldFile = albumCoverPath {
      let oldPath = documentsDirectory.appendingPathComponent(oldFile).path
      if FileManager.default.fileExists(atPath: oldPath) {
        try? FileManager.default.removeItem(atPath: oldPath)
      }
    }
    
    let path = "\(UUID().uuidString).jpeg"
    
    let url = documentsDirectory.appendingPathComponent(path)
    do {
      try jpeg.write(to: url)
      albumCoverPath = path
    } catch {
      albumCoverPath = nil
      print(error)
    }
  }
}
