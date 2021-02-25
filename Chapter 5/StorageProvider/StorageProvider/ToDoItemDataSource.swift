import CoreData

public class ToDoItemDataSource {
  private var fetchedIDs: [NSManagedObjectID] = []
  private var objects: [NSManagedObjectID: ToDoItem] = [:]
  private let persistentContainer: PersistentContainer

  public var numberOfItems: Int { fetchedIDs.count }

  public init(persistentContainer: PersistentContainer) {
    self.persistentContainer = persistentContainer
  }

  public func fetch(_ completion: @escaping () -> Void) {
    persistentContainer.performBackgroundTask { [weak self] context in
      context.perform {
        let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "ToDoItem")
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        request.propertiesToFetch = ["dueDate"]
        request.resultType = .managedObjectIDResultType

        self?.fetchedIDs = (try? context.fetch(request)) ?? []

        completion()
      }
    }
  }

  public func object(at index: Int) -> ToDoItem? {
    let id = fetchedIDs[index]

    if let object = objects[id] {
      return object
    }

    let viewContext = persistentContainer.viewContext
    if let object = try? viewContext.existingObject(with: id) as? ToDoItem {
      objects[id] = object
      return object
    }

    return nil
  }

  public func generateAndInsertUsingChildContext() {
    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    childContext.parent = persistentContainer.viewContext

    childContext.perform { [unowned self] in
      for _ in (0..<2) {
        let item = ToDoItem(context: childContext)
        item.title = "Todo item \(UUID().uuidString)"
        item.dueDate = Date().addingTimeInterval(3600)
      }

      do {
        try childContext.save()
        try self.persistentContainer.viewContext.save()
        print("added item")
      } catch {
        print("error: \(error)")
        childContext.rollback()
      }
    }
  }

  public func generateAndInsertUsingBgContext() {
    persistentContainer.performBackgroundTask { context in
      for _ in (0..<2) {
        let item = ToDoItem(context: context)
        item.title = "Todo item \(UUID().uuidString)"
        item.dueDate = Date().addingTimeInterval(3600)
      }

      do {
        try context.save()
        try? self.persistentContainer.viewContext.setQueryGenerationFrom(.current)
        self.persistentContainer.viewContext.refreshAllObjects()
        print("added item")
      } catch {
        print("error: \(error)")
        context.rollback()
      }
    }
  }
}
