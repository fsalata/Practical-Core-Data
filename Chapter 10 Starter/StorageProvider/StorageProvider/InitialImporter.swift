import CoreData
import Foundation
import Combine
import UIKit

class InitialImporter {
  private let persistentContainer: PersistentContainer
  private var cancellables = Set<AnyCancellable>()
  
  init(container: PersistentContainer) {
    self.persistentContainer = container
  }
  
  deinit {
    print("bye")
  }
  
  func importIfNeeded() {
    guard UserDefaults.standard.bool(forKey: "didImport") == false else {
      return
    }
    
    let context = persistentContainer.newBackgroundContext()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(contextDidSave),
                                           name: NSManagedObjectContext.didSaveObjectIDsNotification,
                                           object: context)
    
    let albumsFile = Bundle(for: InitialImporter.self).url(forResource: "albums", withExtension: "json")!
    let data = try! Data(contentsOf: albumsFile)
    let decoder = JSONDecoder()
    let info = try! decoder.decode([ArtistInfo].self, from: data)
    
    let fullFormatter = DateFormatter()
    fullFormatter.dateFormat = "yyyy-MM-dd"
    
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy"
    
    info.publisher.flatMap({ (artistInfo: ArtistInfo) -> AnyPublisher<Album, Never> in
      let artist = Artist(context: context)
      artist.name = artistInfo.name
      
      return artistInfo.albums.publisher.flatMap({ (albumInfo: AlbumInfo) -> AnyPublisher<Album, Never> in
        let album = Album(context: context)
        album.artist = artist
        album.genre = albumInfo.genre
        album.title = albumInfo.name
        if let date = fullFormatter.date(from: albumInfo.releaseDate) {
          album.releaseDate = date
        } else if let date = yearFormatter.date(from: albumInfo.releaseDate) {
          album.releaseDate = date
        }
        
        return URLSession.shared.dataTaskPublisher(for: URL(string: albumInfo.albumCover)!)
          .map(\.data)
          .map({ UIImage(data: $0) })
          .replaceError(with: nil)
          .map({ image in
            album.albumCover = image
            
            return album
          }).eraseToAnyPublisher()
      }).eraseToAnyPublisher()
    }).sink(receiveCompletion: { completion in
      if case .finished = completion {
        print("Imported everything, will save now")
        try! context.save()
        UserDefaults.standard.set(true, forKey: "didImport")
      } else {
        print(completion)
      }
    }, receiveValue: { album in
      print("Imported \(album.title)")
    }).store(in: &cancellables)
  }
  
  @objc func contextDidSave(_ notification: Notification) {
    print("Updating view context")
    persistentContainer.viewContext.mergeChanges(fromContextDidSave: notification)
  }
}

struct ArtistInfo: Decodable {
  let name: String
  let albums: [AlbumInfo]
}

struct AlbumInfo: Decodable {
  let name: String
  let releaseDate: String
  let albumCover: String
  let genre: String
}
