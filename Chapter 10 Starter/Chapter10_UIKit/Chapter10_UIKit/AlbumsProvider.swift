import StorageProvider
import CoreData
import UIKit

class AlbumsProvider: NSObject {
  fileprivate let fetchedResultsController: NSFetchedResultsController<Album>
  @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?

  init(storageProvider: StorageProvider) {
    let request = Album.byArtistAndNameRequest
    self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                               managedObjectContext: storageProvider.persistentContainer.viewContext,
                                                               sectionNameKeyPath: nil, cacheName: nil)

    super.init()

    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
  }

  func object(at indexPath: IndexPath) -> Album {
    return fetchedResultsController.object(at: indexPath)
  }
}

extension AlbumsProvider: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

    let idsToReload = newSnapshot.itemIdentifiers.filter({ identifier in
      // check if this identifier is in the old snapshot
      // and that it didn't move to a new position
      guard let oldIndex = self.snapshot?.indexOfItem(identifier),
            let newIndex = newSnapshot.indexOfItem(identifier),
            oldIndex == newIndex else {
        return false
      }

      // check if we need to update this object
      guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else {
        return false
      }

      return true
    })

    newSnapshot.reloadItems(idsToReload)

    self.snapshot = newSnapshot
  }
}
