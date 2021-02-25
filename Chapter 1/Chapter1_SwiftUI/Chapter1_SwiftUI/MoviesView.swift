import SwiftUI
import StorageProvider

struct MoviesView: View {
  let storageProvider: StorageProvider

  @State var movieTitle = ""
  @State var movies: [Movie] = []

  var body: some View {
    VStack {
      Text("Add a movie")
        .font(.title)
        .padding()

      TextField("Movie name", text: $movieTitle)
        .padding()

      HStack {
        Button("Save movie") {
          storageProvider.saveMovie(named: movieTitle)
        }

        Spacer()

        Button("Fetch all movies") {
          movies = storageProvider.getAllMovies()
        }
      }.padding()

      List {
        ForEach(movies) { (movie: Movie) in
          Text(movie.name ?? "")
        }.onDelete { rows in
          for row in rows {
            let movie = movies[row]
            storageProvider.deleteMovie(movie)
          }

          movies.remove(atOffsets: rows)
        }
      }
    }
  }
}
