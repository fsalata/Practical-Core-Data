import SwiftUI
import CoreData
import StorageProvider

struct AddAlbumView: View {
  let storageProvider: StorageProvider
  let context: NSManagedObjectContext
  var dismiss: () -> Void
  
  @ObservedObject var album: Album
  
  @State var isErrorPresented = false
  @State var isPresentingPicker = false
  
  @State var artistName: String
  @State var selectedPhoto: UIImage? {
    didSet {
      if let image = selectedPhoto {
        album.setAlbumCover(image)
      } else {
        album.albumCoverPath = nil
      }
    }
  }
  
  init(storageProvider: StorageProvider, dismiss: @escaping () -> Void, album: Album? = nil) {
    self.storageProvider = storageProvider
    self.dismiss = dismiss
    self._artistName = State(wrappedValue: album?.artist.name ?? "")
    
    self.context = storageProvider.childViewContext()
    if let objectId = album?.objectID,
       let album = try? context.existingObject(with: objectId) as? Album {
      self.album = album
    } else {
      self.album = Album(context: context)
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Album info"), content: {
          TextField("Artist name", text: $artistName)
          TextField("Album title", text: $album.title)
          TextField("Genre", text: $album.genre)
          DatePicker(selection: $album.releaseDate, in: ...Date(), displayedComponents: .date) {
            Text("Release date")
          }
        })
        
        Section(header: Text("Album Cover"), content: {
          HStack {
            if let photo = album.albumCover {
              Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 85, height: 85)
                .cornerRadius(8)
                .clipped()
            } else {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
                .frame(width: 85, height: 85)
            }
            
            Button("Select photo") {
              isPresentingPicker = true
            }
          }
        })
      }
      .navigationBarItems(
        leading: Button("Cancel") {
          dismiss()
        }, trailing: Button("Save") {
          do {
            let artist = Artist.findOrInsert(using: artistName,
                                             in: context)
            album.artist = artist

            try context.save()
            try storageProvider.persistentContainer.viewContext.save()
            dismiss()
          } catch {
            print("Something went wrong \(error)")
            isErrorPresented = true
          }
        })
      .navigationBarTitle("Add New Album")
      .sheet(isPresented: $isPresentingPicker, content: {
        PhotoPicker(selectedPhoto: $selectedPhoto, dismiss: { self.isPresentingPicker = false })
      })
      .alert(isPresented: $isErrorPresented, content: {
        Alert(title: Text("Something went wrong"),
              message: Text("Ensure that all fields are filled"),
              dismissButton: .default(Text("Ok")))
      })
    }
  }
}
