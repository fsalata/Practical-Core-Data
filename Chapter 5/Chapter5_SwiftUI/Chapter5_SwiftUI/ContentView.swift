import SwiftUI
import StorageProvider
import CoreData

struct ContentView: View {
  let storageProvider: StorageProvider
  let itemSource: ToDoItemDataSource

  @State var numberOfItems = 0

  init(storageProvider: StorageProvider) {
    self.storageProvider = storageProvider
    self.itemSource = ToDoItemDataSource(persistentContainer: storageProvider.persistentContainer)
  }

  var body: some View {
    VStack(spacing: 8) {
      HStack {
        Spacer()
        Button("Add new items") {
          //itemSource.generateAndInsertUsingChildContext()
          itemSource.generateAndInsertUsingBgContext()
        }
        Spacer()
        Button("Load items") {
          itemSource.fetch({
            DispatchQueue.main.async {
              numberOfItems = itemSource.numberOfItems
            }
          })
        }
        Spacer()
      }

      List(0..<numberOfItems, id: \.self) { idx -> Text in
        let item = itemSource.object(at: idx)

        return Text(item?.title ?? "--")
      }
    }
  }
}
