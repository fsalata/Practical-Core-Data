import StorageProvider
import CoreData

class AlbumsProvider: NSObject, ObservableObject {
  fileprivate let fetchedResultsController: NSFetchedResultsController<Album>
  
  var numberOfSections: Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  init(storageProvider: StorageProvider) {
    let request = Album.byArtistAndNameRequest
    self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                               managedObjectContext: storageProvider.persistentContainer.viewContext,
                                                               sectionNameKeyPath: nil, cacheName: nil)
    
    super.init()
    
    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
  }
  
  func numberOfItemsInSection(_ section: Int) -> Int {
    guard let sections = fetchedResultsController.sections,
          sections.endIndex > section else {
      return 0
    }
    
    return sections[section].numberOfObjects
  }
  
  func object(at indexPath: IndexPath) -> Album {
    return fetchedResultsController.object(at: indexPath)
  }
}

extension AlbumsProvider: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    objectWillChange.send()
  }
}
