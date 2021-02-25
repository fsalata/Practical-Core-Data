import SwiftUI
import StorageProvider

struct AlbumDetailView: View {
  static let albumDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()
  
  let storageProvider: StorageProvider
  @ObservedObject var album: Album

  @State var presentedSheet: PresentedSheet?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if let cover = album.albumCover {
        Image(uiImage: cover)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 160, height: 160)
          .cornerRadius(16)
          .clipped()
      }
      
      
      NavigationLink(destination: ArtistDetailView(artist: album.artist,
                                                   storageProvider: storageProvider)) {
        Text("\(album.artist.name)")
          .font(.title2)
          .bold()
      }

      Text(album.title)
        .bold()
        .padding([.bottom], 16)
      Text("Genre: ").bold() + Text(album.genre)
      Text("Released: ").bold() + Text("\(album.releaseDate, formatter: Self.albumDateFormat)")

      HStack {
        Text("Notes")
          .bold()
          .padding([.top], 16)

        Spacer()

        Button(action: {
          presentedSheet = .addNote
        }, label: {
          Text("Add new")
        })
      }
      List(album.sortedSessions) { session in
        VStack {
          Text(session.notes)
        }
      }
      
      Spacer()
    }
    .padding(16)
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    .navigationBarItems(trailing: Button("Edit") {
      presentedSheet = .editAlbum
    })
    .navigationBarTitle(Text(album.title), displayMode: .inline)
    .sheet(item: $presentedSheet) { item in
      switch item {
      case .editAlbum:
        AddAlbumView(storageProvider: storageProvider,
                     dismiss: { self.presentedSheet = nil },
                     album: album)
      case .addNote:
        AddNoteView(storageProvider: storageProvider,
                    dismiss: { self.presentedSheet = nil },
                    album: album)
      }

    }
  }
}

extension AlbumDetailView {
  enum PresentedSheet: Identifiable {
    case editAlbum, addNote

    var id: Int {
      self.hashValue
    }
  }
}
