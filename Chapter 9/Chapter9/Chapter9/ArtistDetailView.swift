import SwiftUI
import StorageProvider

struct ArtistDetailView: View {
  @ObservedObject var artist: Artist
  let storageProvider: StorageProvider
  
  @State var isEditViewPresented = false
  
  var body: some View {
    List(Array(artist.albums)) { album in
      AlbumCell(album: album)
    }
      .navigationBarItems(trailing: Button("Edit") {
        isEditViewPresented = true
      })
      .navigationBarTitle(Text(artist.name), displayMode: .inline)
      .sheet(isPresented: $isEditViewPresented, content: {
        EditArtistView(storageProvider: storageProvider,
                       dismiss: { self.isEditViewPresented = false },
                       artist: artist)
      })
  }
}
