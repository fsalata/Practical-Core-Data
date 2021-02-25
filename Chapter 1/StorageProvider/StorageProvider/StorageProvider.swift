import CoreData

/// I'm using a subclass of `NSPersistentContainer` so it looks for my xcdatamodel in the framework bundle rather than my app/main bundle.
/// You don't need a subclass if you're not using your persistent container in a framework.
public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {

  public let persistentContainer: NSPersistentContainer

  public init() {
    persistentContainer = PersistentContainer(name: "Chapter1")

    persistentContainer.loadPersistentStores(completionHandler: { description, error in
      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })
  }
}

public extension StorageProvider {
  func saveMovie(named name: String) {
    let movie = Movie(context: persistentContainer.viewContext)
    movie.name = name

    do {
      try persistentContainer.viewContext.save()
      print("Movie saved succesfully")
    } catch {
      persistentContainer.viewContext.rollback()
      print("Failed to save movie: \(error)")
    }
  }
}

public extension StorageProvider {
  func getAllMovies() -> [Movie] {
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()

    do {
      return try persistentContainer.viewContext.fetch(fetchRequest)
    } catch {
      print("Failed to fetch movies: \(error)")
      return []
    }
  }
}

public extension StorageProvider {
  func deleteMovie(_ movie: Movie) {
    persistentContainer.viewContext.delete(movie)

    do {
      try persistentContainer.viewContext.save()
    } catch {
      persistentContainer.viewContext.rollback()
      print("Failed to save context: \(error)")
    }
  }

  func updateMovie(_ movie: Movie) {
    do {
      try persistentContainer.viewContext.save()
    } catch {
      persistentContainer.viewContext.rollback()
      print("Failed to save context: \(error)")
    }
  }
}
