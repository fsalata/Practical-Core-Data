import Foundation
import CoreData

class PersistentHistoryTracker {
  private let persistentContainer: NSPersistentContainer
  private let actor: StorageActor

  init(persistentContainer: NSPersistentContainer, actor: StorageActor) {
    self.persistentContainer = persistentContainer
    self.actor = actor

    NotificationCenter.default.addObserver(self, selector: #selector(processChanges),
                                           name: .NSPersistentStoreRemoteChange,
                                           object: persistentContainer.persistentStoreCoordinator)
  }

  func lastUpdated() -> Date? {
    return UserDefaults.shared.object(forKey: "PersistentHistoryTracker.lastUpdate.\(actor.rawValue)") as? Date
  }

  func persistLastUpdated(_ date: Date) {
    return UserDefaults.shared.set(date, forKey: "PersistentHistoryTracker.lastUpdate.\(actor.rawValue)")
  }

  func leastRecentUpdate() -> Date? {
    return StorageActor.allCases.reduce(nil) { currentLeastRecent, actor in
      guard let updateDate = UserDefaults.shared.object(forKey: "PersistentHistoryTracker.lastUpdate.\(actor.rawValue)") as? Date else {
        return currentLeastRecent
      }

      if let oldDate = currentLeastRecent {
        return min(oldDate, updateDate)
      }

      return updateDate
    }
  }

  @objc public func processChanges() {
    let lastDate = self.lastUpdated() ?? .distantPast
    let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastDate)

    let context = persistentContainer.viewContext

    context.perform { [unowned self] in
      do {
        guard let result = try context.execute(request) as? NSPersistentHistoryResult,
              let history = result.result as? [NSPersistentHistoryTransaction],
              !history.isEmpty else {
          return
        }

        for transaction in history {
          let notification = transaction.objectIDNotification()
          context.mergeChanges(fromContextDidSave: notification)

          self.persistLastUpdated(transaction.timestamp)
        }

        if let lastTimestamp = leastRecentUpdate() {
          let deleteRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: lastTimestamp)
          try context.execute(deleteRequest)
        }
      } catch {
        print(error)
      }
    }
  }
}

public enum StorageActor: String, CaseIterable {
  case swiftuiApp, uikitApp
}
