import SwiftUI
import StorageProvider
import CoreData

struct FetchRequestMoviesView: View {
  @FetchRequest var movies: FetchedResults<Movie>

  init(request: NSFetchRequest<Movie>) {
    _movies = FetchRequest(fetchRequest: request)
  }

  var body: some View {
    List(movies) { movie in
      Text(movie.title ?? "--")
    }
  }
}
