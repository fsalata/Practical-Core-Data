import SwiftUI
import StorageProvider
import CoreData

struct EditArtistView: View {
  let storageProvider: StorageProvider
  let context: NSManagedObjectContext
  var dismiss: () -> Void
  
  @ObservedObject var artist: Artist
  
  @State var isErrorPresented = false
  
  init(storageProvider: StorageProvider, dismiss: @escaping () -> Void, artist: Artist) {
    self.storageProvider = storageProvider
    self.dismiss = dismiss
    
    self.context = storageProvider.childViewContext()
    if let artist = try? context.existingObject(with: artist.objectID) as? Artist {
      self.artist = artist
    } else {
      self.artist = Artist(context: context)
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Artist info"), content: {
          TextField("Artist name", text: $artist.name)
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
            for album in artist.albums {
              if let sourceAlbum = try? viewContext.existingObject(with: album.objectID) {
                viewContext.refresh(sourceAlbum, mergeChanges: true)
              }
            }
            dismiss()
          } catch {
            print("Something went wrong \(error)")
            isErrorPresented = true
          }
        })
      .navigationBarTitle("Edit Artist")
      .alert(isPresented: $isErrorPresented, content: {
        Alert(title: Text("Something went wrong"),
              message: Text("Ensure that all fields are filled"),
              dismissButton: .default(Text("Ok")))
      })
    }
  }
}
