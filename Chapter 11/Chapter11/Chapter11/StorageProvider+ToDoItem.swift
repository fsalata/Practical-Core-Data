import CoreData

public extension StorageProvider {
  func addToDoItem(title: String, dueDate: Date?, in context: NSManagedObjectContext) {
    context.performAndWait {
      let item = ToDoItem(context: context)
      item.title = title
      item.dueDate = dueDate

      do {
        try context.save()
      } catch {
        // you'll want to handle errors here
        context.rollback()
      }
    }
  }
}
