import CoreData

public class ListeningSession: NSManagedObject, Identifiable {
  @NSManaged public var notes: String
  @NSManaged public var date: Date?
  @NSManaged public var album: Album
}
