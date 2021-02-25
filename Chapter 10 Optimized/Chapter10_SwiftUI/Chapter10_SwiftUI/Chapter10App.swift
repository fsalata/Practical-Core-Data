import SwiftUI
import StorageProvider

@main
struct Chapter10App: App {
  @State var storageProvider = StorageProvider()

  var body: some Scene {
    WindowGroup {
      AlbumsOverview(storageProvider: storageProvider,
                     albumsProvider: AlbumsProvider(storageProvider: storageProvider))
        .environment(\.managedObjectContext,
                     storageProvider.persistentContainer.viewContext)
    }
  }
}
