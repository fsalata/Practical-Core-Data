import SwiftUI
import StorageProvider

struct ContentView: View {

  @FetchRequest(entity: ToDoItem.entity(),
                sortDescriptors: [
                  NSSortDescriptor(keyPath: \ToDoItem.dueDate,
                                   ascending: true)
                ]) var allItems: FetchedResults<ToDoItem>

  let storageProvider: StorageProvider

  var body: some View {
    VStack {
      HStack {
        Spacer()

        Button("Insert items") {
          storageProvider.generateAndInsertObjects()
        }

        Spacer()

        Button("Delete all") {
          storageProvider.deleteAllObjects()
        }
        .foregroundColor(.red)
        .font(Font.body.bold())

        Spacer()
      }
      List(allItems) { (item: ToDoItem) in
        Text(item.title ?? "--")
      }
    }
  }
}
