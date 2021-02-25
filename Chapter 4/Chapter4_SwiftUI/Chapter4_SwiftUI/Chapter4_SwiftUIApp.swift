import SwiftUI
import StorageProvider

@main
struct Chapter4_SwiftUIApp: App {
  let storageProvider = StorageProvider()
  
  var body: some Scene {
    WindowGroup {
      TabView {
        MoviesView(viewModel: MoviesViewModel(storageProvider: storageProvider))
          .tabItem {
            Image(systemName: "film")
            Text("Movies")
          }
        
        FetchRequestMoviesView(request: storageProvider.oldMovies)
          .environment(\.managedObjectContext, storageProvider.persistentContainer.viewContext)
          .tabItem {
            Image(systemName: "film")
            Text("@FetchRequest<Movie>")
          }
        
        ImportView(viewModel: ImportViewModel(storageProvider: storageProvider))
          .tabItem {
            Image(systemName: "icloud.and.arrow.down")
            Text("Import")
          }
      }
    }
  }
}
