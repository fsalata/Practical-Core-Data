import Foundation
import Combine
import CoreData

public class MovieDbImporter {
  private static var syncQueue = DispatchQueue(label: "MovieDbImporter.queue")
  private static var _isRunning: Bool = false
  public static var isRunning: Bool {
    get { return syncQueue.sync { _isRunning }}
    set { syncQueue.sync{ _isRunning = newValue }}
  }

  public init() {}

  public func importNextPage(in context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
    guard !Self.isRunning else {
      return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    Self.isRunning = true

    let session = MovieDbAPI.Session()

    var page = 1
    context.performAndWait {
      let req: NSFetchRequest<Movie> = Movie.fetchRequest()
      let count = try! context.count(for: req)
      page = (count / 20) + 1 // 20 == movie db page size
    }

    let request = MovieDbAPI.DiscoverApi.RequestParams(sorting: "popularity.desc",
                                                       page: page,
                                                       releasedBefore: "1603915290")

    return session.discover.load(request)
      .map(\.results)
      .flatMap({ (movies) -> AnyPublisher<[MovieDbAPI.Movie], Error> in
        print("Retrieved \(movies.count) movies")

        return movies
          .publisher
          .flatMap({ (movie) -> AnyPublisher<MovieDbAPI.Movie, Error> in
            print("post processing \(movie.id)")
            return session.movie.credits(movie.id)
              .map({ response in
                print("enriching movie \(movie.id)")
                var _movie = movie
                _movie.cast = response.cast
                return _movie
              })
              .eraseToAnyPublisher()
          })
          .collect()
          .eraseToAnyPublisher()
      })
      .reduce([MovieDbAPI.Movie]()) { $0 + $1 }
      .handleEvents(receiveOutput: { movies in
        context.performAndWait {
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd"

          for movie in movies {
            let managedMovie = Movie(context: context)
            managedMovie.externalId = Int64(movie.id)
            managedMovie.popularity = movie.popularity
            managedMovie.overview = movie.overview
            managedMovie.posterPath = movie.posterPath
            managedMovie.title = movie.title
            managedMovie.releaseDate = formatter.date(from: movie.releaseDate)!

            for credit in movie.cast ?? [] {
              let managedActor = Actor(context: context)
              managedActor.externalId = Int64(credit.id)
              managedActor.name = credit.name

              let managedCharacter = Character(context: context)
              managedCharacter.externalId = Int64(credit.castId)
              managedCharacter.name = credit.character

              managedActor.addToCharacters(managedCharacter)
              managedActor.addToMovies(managedMovie)
            }
          }

          defer {
            Self.isRunning = false
          }

          do {
            try context.save()
          } catch {
            print("something went wrong: \(error)")
          }
        }
      })
      .map({ _ in return () })
      .eraseToAnyPublisher()
  }
}
