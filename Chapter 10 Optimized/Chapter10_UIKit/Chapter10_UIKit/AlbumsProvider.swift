import StorageProvider
import CoreData
import Combine
import UIKit

class AlbumsProvider: NSObject {
  fileprivate let fetchedResultsController: NSFetchedResultsController<Album>
  
  let controllerDidChangePublisher = PassthroughSubject<[Change], Never>()
  var inProgressChanges: [Change] = []
  
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
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    inProgressChanges.removeAll()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    if type == .insert {
      inProgressChanges.append(.section(.inserted(sectionIndex)))
    } else if type == .delete {
      inProgressChanges.append(.section(.deleted(sectionIndex)))
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    // indexPath and newIndexPath are force unwrapped based on whether they should / should not be present according to the docs.
    switch type {
    case .insert:
      inProgressChanges.append(.object(.inserted(at: newIndexPath!)))
    case .delete:
      inProgressChanges.append(.object(.deleted(from: indexPath!)))
    case .move:
      inProgressChanges.append(.object(.moved(from: indexPath!, to: newIndexPath!)))
    case .update:
      inProgressChanges.append(.object(.updated(at: indexPath!)))
    default:
      break
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    controllerDidChangePublisher.send(inProgressChanges)
  }
}

enum Change: Hashable {
  enum SectionUpdate: Hashable {
    case inserted(Int)
    case deleted(Int)
  }
  
  enum ObjectUpdate: Hashable {
    case inserted(at: IndexPath)
    case deleted(from: IndexPath)
    case updated(at: IndexPath)
    case moved(from: IndexPath, to: IndexPath)
  }
  
  case section(SectionUpdate)
  case object(ObjectUpdate)
}
