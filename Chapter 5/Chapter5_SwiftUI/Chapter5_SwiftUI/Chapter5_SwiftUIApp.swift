import SwiftUI
import StorageProvider

@main
struct Chapter5_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(storageProvider: StorageProvider())
        }
    }
}
