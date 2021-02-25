import CoreData

public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {

  public let persistentContainer: PersistentContainer

  public init() {
    persistentContainer = PersistentContainer(name: "Chapter4")

    persistentContainer.loadPersistentStores(completionHandler: { description, error in
      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })

    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
  }
}

public extension StorageProvider {
  var minDate: Date {
    let components = DateComponents(calendar: Calendar.current, year: 1950)
    return components.date ?? Date()
  }

  var maxDate: Date {
    let components = DateComponents(calendar: Calendar.current, year: 1990)
    return components.date ?? Date()
  }

  var oldMovies: NSFetchRequest<Movie> {
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.predicate = NSPredicate(format: "%K >= %@ AND %K <= %@",
                                    #keyPath(Movie.releaseDate), minDate as NSDate,
                                    #keyPath(Movie.releaseDate), maxDate as NSDate)
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \Movie.releaseDate, ascending: false)
    ]
    return request
  }
}

// internal object to this framework to demonstrate predicates from the chapter
class ExamplePredicates {
  private let upperBound = Date()
  private let lowerBound = Date().addingTimeInterval(-3600)
  private let someDate = Date()

  lazy var oldMoviesPredicate = NSPredicate(format: "%K <= %@",
                                            #keyPath(Movie.releaseDate), someDate as NSDate)

  lazy var moviesPredicate = NSPredicate(format: "%K <= %@ AND %K >= %@",
                                         #keyPath(Movie.releaseDate), upperBound as NSDate,
                                         #keyPath(Movie.releaseDate), lowerBound as NSDate)

  let minRating = 8

  // upperBound and lowerBound are both dates to specify the movie's max and min age
  lazy var ratedPredicate = NSPredicate(format: "(%K <= %@ AND %K >= %@) OR %K > %@",
                                        #keyPath(Movie.releaseDate), upperBound as NSDate,
                                        #keyPath(Movie.releaseDate), lowerBound as NSDate,
                                        #keyPath(Movie.rating), minRating)

  // This predicate is not compatible with the model used in the sample app
  // It's in the code bundle just for reference
//  lazy var starPredicate = NSPredicate(format: "%K BEGINSWITH[cd] %@",
//                                       #keyPath(Character.movie.title), "Star")

  lazy var noStarPredicate = NSPredicate(format: "NOT %K BEGINSWITH[cd] %@",
                                         #keyPath(Movie.title), "Star")

  func buildCompoundPredicate() {
    let minDatePredicate = NSPredicate(format: "%K >= %@",
                                       #keyPath(Movie.releaseDate), lowerBound as NSDate)
    let maxDatePredicate = NSPredicate(format: "%K <= %@",
                                       #keyPath(Movie.releaseDate), upperBound as NSDate)
    let dateBetween = NSCompoundPredicate(andPredicateWithSubpredicates: [minDatePredicate, maxDatePredicate])
    let ratingPredicate = NSPredicate(format: "%K > %@",
                                      #keyPath(Movie.rating), minRating)
    let _ = NSCompoundPredicate(orPredicateWithSubpredicates: [dateBetween, ratingPredicate])
  }
}

class SortingExample {
  // This request is not compatible with the model used in the sample app
  // It's in the code bundle just for reference

//  lazy var sortedVideoItems: NSFetchRequest<VideoItem> = {
//    let request: NSFetchRequest<VideoItem> = VideoItem.fetchRequest()
//    request.sortDescriptors = [
//      NSSortDescriptor(keyPath: \VideoItem.rating, ascending: false),
//      NSSortDescriptor(keyPath: \VideoItem.releaseDate, ascending: true)
//    ]
//    return request
//  }()
}
