import XCTest
import CoreData
@testable import StorageProvider

extension MigrationTest {
  func validateAlbumv2(_ managedObject: NSManagedObject, using album: Albumv2) throws {
    let artist = try XCTUnwrap(managedObject.value(forKey: "artist") as? String)
    XCTAssertEqual(artist, album.artist)
    
    let title = try XCTUnwrap(managedObject.value(forKey: "title") as? String)
    XCTAssertEqual(title, album.title)
    
    let genre = try XCTUnwrap(managedObject.value(forKey: "genre") as? String)
    XCTAssertEqual(genre, album.genre)
    
    let listeningNotes = try XCTUnwrap(managedObject.value(forKey: "listeningNotes") as? String)
    XCTAssertEqual(listeningNotes, album.listeningNotes)
    
    let releaseDate = try XCTUnwrap(managedObject.value(forKey: "releaseDate") as? Date)
    XCTAssertEqual(releaseDate, album.releaseDate)
    
    let albumCover = managedObject.value(forKey: "albumCover") as? Data
    XCTAssertEqual(albumCover, album.albumCover)
  }
}

struct Albumv2 {
  let artist: String
  let title: String
  let genre: String
  let listeningNotes: String
  let releaseDate: Date
  let albumCover: Data?
}
