import CoreData
import UIKit
import Foundation

public class Album: NSManagedObject, Identifiable {
  public static var byArtistAndNameRequest: NSFetchRequest<Album> {
    let request: NSFetchRequest<Album> = Album.fetchRequest()
    
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \Album.artist, ascending: true),
      NSSortDescriptor(keyPath: \Album.title, ascending: true)
    ]

    request.fetchBatchSize = 15
    
    return request
  }
  
  public static func fetchRequest() -> NSFetchRequest<Album> {
    return NSFetchRequest<Album>(entityName: "Album")
  }
  
  @NSManaged public var genre: String
  @NSManaged public var releaseDate: Date
  @NSManaged public var title: String
  @NSManaged public var albumCover: UIImage?
  //@NSManaged public var artist: String
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
}
