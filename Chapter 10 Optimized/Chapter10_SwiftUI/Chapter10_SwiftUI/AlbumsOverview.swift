import StorageProvider
import SwiftUI

struct AlbumsOverview: View {
  let storageProvider: StorageProvider
  @ObservedObject var albumsProvider: AlbumsProvider
  
  @State var isAddAlbumPresented = false
  
  var body: some View {
    NavigationView {
      List(0..<albumsProvider.numberOfItemsInSection(0), id: \.self) { index in
        let album = albumsProvider.object(at: IndexPath(item: index, section: 0))
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
