import SwiftUI
import Chapter7
import CoreData

@main
struct Chapter7_SwiftUIApp: App {
  let storageProvider = StorageProvider()
  let synchronizer: Synchronizer

  var viewContext: NSManagedObjectContext {
    storageProvider.persistentContainer.viewContext
  }
  
  init() {
    let context = storageProvider.persistentContainer.newBackgroundContext()
    context.automaticallyMergesChangesFromParent = true
    synchronizer = Synchronizer(context: context)
    synchronizer.start()
  }

  var body: some Scene {
    WindowGroup {
      ContentView(importer: DataImporter(context: viewContext))
        .environment(\.managedObjectContext, viewContext)
    }
  }
}
