import SwiftUI
import CoreData
import StorageProvider

struct AddNoteView: View {
  let storageProvider: StorageProvider
  let context: NSManagedObjectContext
  var dismiss: () -> Void

  @ObservedObject var note: ListeningSession

  @State var isErrorPresented = false

  init(storageProvider: StorageProvider, dismiss: @escaping () -> Void, album: Album) {
    self.storageProvider = storageProvider
    self.dismiss = dismiss

    self.context = storageProvider.childViewContext()
    self.note = ListeningSession(context: context)

    // force unwrap because we know the album exists
    note.album = try! context.existingObject(with: album.objectID) as! Album
    note.date = Date()
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Notes"), content: {
          TextEditor(text: $note.notes)
            .frame(height: 200)
        })
      }
      .navigationBarItems(
        leading: Button("Cancel") {
          dismiss()
        }, trailing: Button("Save") {
          do {
            let viewContext = storageProvider.persistentContainer.viewContext
            try context.save()
            try viewContext.save()
            dismiss()
          } catch {
            print("Something went wrong \(error)")
            isErrorPresented = true
          }
        })
      .navigationBarTitle("Add Note")
      .alert(isPresented: $isErrorPresented, content: {
        Alert(title: Text("Something went wrong"),
              message: Text("Ensure that all fields are filled"),
              dismissButton: .default(Text("Ok")))
      })
    }
  }
}
