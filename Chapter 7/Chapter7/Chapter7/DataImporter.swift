import Foundation
import CoreData

public class DataImporter {
  public static var sampleData: Data {
    let url = Bundle(for: Self.self).url(forResource: "sample_data", withExtension: "json")

    return try! Data(contentsOf: url!)
  }

  private let context: NSManagedObjectContext

  public init(context: NSManagedObjectContext) {
    self.context = context
  }

  public func importData<T: NSManagedObject & Decodable>(_ data: Data, as model: T.Type) {
    self._importData(data, as: model)
  }

  public func importData<T: Collection & Decodable>(_ data: Data, as model: T.Type) where T.Element: NSManagedObject {
    self._importData(data, as: model)
    //importPointsOfInterest(data)
  }
  
  public func importPointsOfInterestUsingData(_ data: Data) {
    let entries = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
    for entry in entries {
      let uuid = UUID(uuidString: entry["identifier"] as! String)!
      let poi = PointOfInterest.findOrInsert(using: uuid, in: self.context)
      
      if poi.objectID.isTemporaryID || poi.synchronizationState == .synchronized {
        poi.address = entry["address"] as! String
        poi.city = entry["city"] as! String
        poi.country = entry["country"] as! String
        poi.identifier = uuid
        poi.information = entry["information"] as! String
        poi.latitude = entry["latitude"] as! Float
        poi.longitude = entry["longitude"] as! Float
        poi.name = entry["name"] as! String
        poi.synchronizationState = .synchronized
      } else {
        // We have local changes, don't update
      }
    }
  }

  private func _importData<T: Decodable>(_ data: Data, as model: T.Type) {
    context.perform { [unowned self] in
      let decoder = JSONDecoder()
      decoder.userInfo[.managedObjectContext] = self.context

      do {
        _ = try decoder.decode(model, from: data)
        try self.context.save()
        self.context.reset()
      } catch {
        if self.context.hasChanges {
          self.context.rollback()
        }

        print("Failed to insert models")
        print(error)
      }
    }
  }

  private func importPointsOfInterest(_ data: Data) {
    context.perform { [unowned self] in

      do {
        var entries = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
        let batchImport = NSBatchInsertRequest(entity: PointOfInterest.entity(), managedObjectHandler: { object in
          let poi = object as! PointOfInterest
          let entry = entries.removeFirst()

          poi.address = entry["address"] as! String
          poi.city = entry["city"] as! String
          poi.country = entry["country"] as! String
          let uuid = UUID(uuidString: entry["identifier"] as! String)!
          poi.identifier = uuid
          poi.information = entry["information"] as! String
          poi.latitude = entry["latitude"] as! Float
          poi.longitude = entry["longitude"] as! Float
          poi.name = entry["name"] as! String

          return entries.isEmpty
        })
        try self.context.execute(batchImport)
      } catch {
        print("Failed to batch import")
        print(error)
      }
    }
  }

  private func optimizedImportData(_ data: Data, as entity: NSEntityDescription) {
    context.perform { [unowned self] in
      do {
        let entries = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
        let batchImport = NSBatchInsertRequest(entity: entity, objects: entries)
        try self.context.execute(batchImport)
      } catch {
        print("Failed to batch import")
        print(error)
      }
    }
  }
}

extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
