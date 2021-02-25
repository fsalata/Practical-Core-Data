import XCTest
import CoreData
@testable import StorageProvider

class MigrationTest: XCTestCase {
  let bundle = Bundle(for: MigrationTest.self)
  
  func prepareStore(using source: String) throws -> URL {
    let sourceURL = bundle.url(forResource: source, withExtension: ".sqlite")!
    let destination = URL(fileURLWithPath: NSTemporaryDirectory(),
                          isDirectory: true).appendingPathComponent(UUID().uuidString)
    
    try FileManager.default.copyItem(at: sourceURL, to: destination)
    
    return destination
  }
}
