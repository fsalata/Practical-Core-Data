import XCTest
import CoreData
@testable import Chapter11

class Chapter11Tests: XCTestCase {
  var storageProvider: StorageProvider = StorageProvider(storeType: .inMemory)

  override func setUpWithError() throws {
    storageProvider = StorageProvider(storeType: .inMemory)
  }

  func testAddItemPersistsToDoItem() throws {
    let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()

    let context = storageProvider.persistentContainer.viewContext
    let initialCount = try context.count(for: request)
    XCTAssertEqual(initialCount, 0)

    storageProvider.addToDoItem(title: "Test item", dueDate: nil,
                                in: context)

    let finalCount = try context.count(for: request)
    XCTAssertEqual(finalCount, 1)
  }

  func testAddItemPersistsToDoItem2() throws {
    let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()

    let context = storageProvider.persistentContainer.viewContext
    let initialCount = try context.count(for: request)
    XCTAssertEqual(initialCount, 0)

    storageProvider.addToDoItem(title: "Test item", dueDate: nil,
                                in: context)

    let finalCount = try context.count(for: request)
    XCTAssertEqual(finalCount, 1)
  }
}
