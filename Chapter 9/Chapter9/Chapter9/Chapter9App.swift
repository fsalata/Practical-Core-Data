import SwiftUI
import StorageProvider

@main
struct Chapter9App: App {
  @State var storageProvider = StorageProvider()

  var body: some Scene {
    WindowGroup {
      AlbumsOverview(storageProvider: storageProvider)
        .environment(\.managedObjectContext,
                     storageProvider.persistentContainer.viewContext)
    }
  }
}
