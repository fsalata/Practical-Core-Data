import Foundation
import CoreData

public class PointOfInterest: NSManagedObject, Codable {
  enum CodingKeys: CodingKey {
    case address, city, country, identifier,
         information, latitude, longitude,
         name, category, updatedAt
  }

  @NSManaged public var address: String
  @NSManaged public var city: String
  @NSManaged public var country: String
  @NSManaged public var identifier: UUID
  @NSManaged public var information: String
  @NSManaged public var latitude: Float
  @NSManaged public var longitude: Float
  @NSManaged public var name: String

  @NSManaged public var category: PoiCategory
  
  // sync related properties
  @NSManaged public var synchronized: Int
  @NSManaged public var updatedAt: Date

  public var synchronizationState: SynchronizationState {
    get {
      SynchronizationState(rawValue: synchronized) ?? .notSynchronized
    }
    
    set {
      synchronized = newValue.rawValue
    }
  }

  public required convenience init(from decoder: Decoder) throws {
    guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
      fatalError("Attempt to decode managed object with misconfigured decoder.")
    }

    self.init(context: context)

    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.address = try container.decode(String.self, forKey: .address)
    self.city = try container.decode(String.self, forKey: .city)
    self.country = try container.decode(String.self, forKey: .country)
    self.identifier = try container.decode(UUID.self, forKey: .identifier)
    self.information = try container.decode(String.self, forKey: .information)
    self.latitude = try container.decode(Float.self, forKey: .latitude)
    self.longitude = try container.decode(Float.self, forKey: .longitude)
    self.name = try container.decode(String.self, forKey: .name)
    self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()

    self.category = try container.decode(PoiCategory.self, forKey: .category)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(address, forKey: .address)
    try container.encode(city, forKey: .city)
    try container.encode(country, forKey: .country)
    try container.encode(identifier, forKey: .identifier)
    try container.encode(information, forKey: .information)
    try container.encode(latitude, forKey: .latitude)
    try container.encode(longitude, forKey: .longitude)
    try container.encode(name, forKey: .name)
    try container.encode(updatedAt, forKey: .updatedAt)
    
    try container.encode(category, forKey: .category)
  }
  
  public override func awakeFromInsert() {
    super.awakeFromInsert()
    setPrimitiveValue(Date(), forKey: #keyPath(PointOfInterest.updatedAt))
  }
  
  public override func willSave() {
    super.willSave()
    setPrimitiveValue(Date(), forKey: #keyPath(PointOfInterest.updatedAt))
  }
}

public enum SynchronizationState: Int {
  case notSynchronized = 0, synchronizationPending, synchronized
}

public extension PointOfInterest {
  static var sortedFetchRequest: NSFetchRequest<PointOfInterest> {
    let sortDescriptors = [NSSortDescriptor(keyPath: \PointOfInterest.name, ascending: true)]
    let request = NSFetchRequest<PointOfInterest>(entityName: "PointOfInterest")
    request.sortDescriptors = sortDescriptors
    return request
  }
  
  static var unsyncedFetchRequest: NSFetchRequest<PointOfInterest> {
    let request = NSFetchRequest<PointOfInterest>(entityName: "PointOfInterest")
    request.predicate = NSPredicate(format: "%K == %d",
                                    #keyPath(PointOfInterest.synchronized),
                                    SynchronizationState.notSynchronized.rawValue)
    
    return request
  }
  
  static func findOrInsert(using identifier: UUID, in context: NSManagedObjectContext) -> PointOfInterest {
    let request = NSFetchRequest<PointOfInterest>(entityName: "PointOfInterest")
    
    request.predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(PointOfInterest.identifier),
                                    identifier as NSUUID)
    
    if let poi = try? context.fetch(request).first {
      return poi
    } else {
      let poi = PointOfInterest(context: context)
      return poi
    }
  }
}

extension PointOfInterest: Identifiable {
  public var id: NSManagedObjectID {
    return objectID
  }
}
