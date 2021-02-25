import CoreData

public extension StorageProvider {
  func generateAndInsertObjects() {
    persistentContainer.performBackgroundTask { context in
      var numberOfInsertedItems = 0

      let batchInsert = NSBatchInsertRequest(entity: ToDoItem.entity()) { (dictionary: NSMutableDictionary) in
        dictionary["dueDate"] = Date().addingTimeInterval(3600)
        dictionary["title"] = "Generated Task \(UUID().uuidString)"

        numberOfInsertedItems += 1

        return numberOfInsertedItems == 10
      }

      do {
        try context.execute(batchInsert)
      } catch {
        print(error)
      }
    }
  }

  func deleteAllObjects() {
    persistentContainer.performBackgroundTask { context in
      let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoItem.fetchRequest()
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      try! context.execute(deleteRequest)
    }
  }
}
