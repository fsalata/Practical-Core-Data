import StorageProvider
import SwiftUI

struct AlbumsOverview: View {
  let storageProvider: StorageProvider
  
  @FetchRequest(fetchRequest: Album.byArtistAndNameRequest)
  var albums: FetchedResults<Album>
  
  @State var isAddAlbumPresented = false
  
  var body: some View {
    NavigationView {
      List(albums) { (album: Album) in
        NavigationLink(destination: AlbumDetailView(storageProvider: storageProvider, album: album)) {
          AlbumCell(album: album)
        }
      }
      .listStyle(PlainListStyle())
      .navigationBarItems(trailing: Button("Add new") {
        isAddAlbumPresented = true
      })
      .navigationBarTitle("My Albums")
      .sheet(isPresented: $isAddAlbumPresented) {
        AddAlbumView(storageProvider: storageProvider,
                     dismiss: { self.isAddAlbumPresented = false })
      }
    }
  }
}
