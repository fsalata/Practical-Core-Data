import SwiftUI
import StorageProvider

@main
struct Chapter6_SwiftUIApp: App {
  let storageProvider = StorageProvider.standard

  var body: some Scene {
    WindowGroup {
      ContentView(storageProvider: storageProvider)
        .environment(\.managedObjectContext, storageProvider.persistentContainer.viewContext)
    }
  }
}

extension StorageProvider {
  static var standard = StorageProvider(.swiftuiApp)
}
