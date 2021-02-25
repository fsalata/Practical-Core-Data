import SwiftUI
import StorageProvider

@main
struct Chapter1_SwiftUIApp: App {
  var body: some Scene {
    WindowGroup {
      MoviesView(storageProvider: StorageProvider())
    }
  }
}
