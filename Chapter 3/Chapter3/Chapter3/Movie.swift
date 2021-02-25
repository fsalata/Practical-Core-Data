import CoreData
import UIKit

public class Movie: NSManagedObject, Identifiable {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
      return NSFetchRequest<Movie>(entityName: "Movie")
  }

  @NSManaged public var releaseDate: Date?
  @NSManaged public var title: String?
  @NSManaged public var duration: Int64
  @NSManaged public var watched: Bool
  @NSManaged public var rating: Double
  @NSManaged public var posterImage: UIImage

  @NSManaged public var cast: Set<Actor>
  @NSManaged public var characters: Set<Character>
  @NSManaged public var directors: Set<Director>
}
