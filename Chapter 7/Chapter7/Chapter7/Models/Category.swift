import Foundation
import CoreData

public class PoiCategory: NSManagedObject, Codable {
  enum CodingKeys: CodingKey {
    case name
  }

  @NSManaged public var name: String
  @NSManaged public var pointsOfInterest: Set<PointOfInterest>

  public required convenience init(from decoder: Decoder) throws {
    guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
      fatalError("Attempt to decode managed object with misconfigured decoder.")
    }

    self.init(context: context)

    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.pointsOfInterest = []
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(name, forKey: .name)
  }
}

extension PoiCategory: Identifiable {
  public var id: NSManagedObjectID {
    return objectID
  }
}
