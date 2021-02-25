import SwiftUI
import Chapter7
import CoreData

struct ContentView: View {
  let importer: DataImporter

  @FetchRequest(fetchRequest: PointOfInterest.sortedFetchRequest)
  var pois: FetchedResults<PointOfInterest>

  @Environment(\.managedObjectContext) var context: NSManagedObjectContext

  var body: some View {
    VStack(spacing: 16) {
      Button("Import some data") {
        let data = DataImporter.sampleData
        importer.importData(data, as: [PointOfInterest].self)
      }

      Button("Insert an unsynced item") {
        let object = pois.first!
        insertNewItemBasedOn(object, in: context)
      }

      List(pois) { (poi: PointOfInterest) in
        VStack(alignment: .leading) {
          Text(poi.name) + Text("(cat: \(poi.category.name))")
          Text("synchronization: \(poi.synchronized)")
        }
      }
    }
  }

  func insertNewItemBasedOn(_ object: PointOfInterest, in context: NSManagedObjectContext) {
    let new = PointOfInterest(context: context)
    new.address = object.address
    new.city = object.city
    new.country = object.country
    new.identifier = UUID()
    new.information = object.information
    new.latitude = object.latitude
    new.longitude = object.longitude
    new.name = "00 Item with name! \(UUID().uuidString)"

    new.category = object.category

    try! context.save()
  }
}
