import SwiftUI
import StorageProvider
import CoreData

struct MoviesView: View {
  @ObservedObject var viewModel: MoviesViewModel

  var body: some View {
    List(viewModel.movies) { (movie: Movie) in
      Text(movie.title ?? "--")
    }
  }
}

class MoviesViewModel: NSObject, ObservableObject {
  @Published var movies = [Movie]()

  private let fetchedResultsController: NSFetchedResultsController<Movie>

  init(storageProvider: StorageProvider) {
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.popularity, ascending: false)]

    self.fetchedResultsController =
      NSFetchedResultsController(fetchRequest: request,
                                 managedObjectContext: storageProvider.persistentContainer.viewContext,
                                 sectionNameKeyPath: nil, cacheName: nil)

    super.init()

    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    movies = fetchedResultsController.fetchedObjects ?? []
  }
}

extension MoviesViewModel: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    movies = controller.fetchedObjects as? [Movie] ?? []
  }
}
