import Foundation
import CoreData
import Combine

public class Synchronizer {
  let context: NSManagedObjectContext
  private var timerCancellable: AnyCancellable?
  
  let networking: Networking
  let importer: DataImporter
  
  public init(context: NSManagedObjectContext, networking: Networking = .init()) {
    self.context = context
    self.networking = networking
    self.importer = DataImporter(context: context)
  }
  
  public func start() {
    guard timerCancellable == nil else {
      return
    }
    
    timerCancellable = Timer.publish(every: 10, on: .current, in: .default)
      .autoconnect()
      .map({ (_) -> [PointOfInterest] in
        let request = PointOfInterest.unsyncedFetchRequest
        let unsynced: [PointOfInterest] = try! self.context.fetch(request)
        return unsynced
      })
      .flatMap({ unsynced -> AnyPublisher<Void, Never> in
        guard !unsynced.isEmpty else {
          return Empty().eraseToAnyPublisher()
        }
        
        
        return self.networking.uploadPointsOfInterest(unsynced)
          .handleEvents(receiveOutput: { output in
            self.context.performAndWait {
              for poi in unsynced {
                print("updating sync status for poi \(poi.identifier)")
                poi.synchronizationState = .synchronized
              }
              
              try! self.context.save()
              
              self.importer.importPointsOfInterestUsingData(output.data)
            }
            
          }, receiveCompletion: { completion in
            if case .failure = completion {
              self.context.performAndWait {
                for poi in unsynced {
                  poi.synchronizationState = .notSynchronized
                }
                
                try! self.context.save()
              }
            }
          })
          .map({ _ in return () })
          .catch({ _ in Empty() })
          .eraseToAnyPublisher()
      })
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in
        print("done!")
      })
  }
}

public class Networking {
  public init() {
    URLProtocol.registerClass(FakeServer.self)
  }

  func uploadPointsOfInterest(_ pointsOfInterest: [PointOfInterest]) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    guard let context = pointsOfInterest.first?.managedObjectContext else {
      fatalError("uploadPointsOfInterest should be called with an array of pois that exist in a managed object context")
    }
    
    context.performAndWait {
      for poi in pointsOfInterest {
        poi.synchronizationState = .synchronizationPending
      }
      
      try! context.save()
    }
    
    let encoder = JSONEncoder()
    let data = try! encoder.encode(pointsOfInterest)

    let url = URL(string: "https://my-server.com/upload")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    FakeServer.preparedData = data
    
    return URLSession.shared.dataTaskPublisher(for: request)
      .eraseToAnyPublisher()
  }
}

class FakeServer: URLProtocol {
  static var preparedData: Data!
  
  override class func canInit(with task: URLSessionTask) -> Bool {
    return task.currentRequest?.url?.absoluteString == "https://my-server.com/upload"
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    DispatchQueue.global().async {
      self.client?.urlProtocol(self, didLoad: Self.preparedData)
      self.client?.urlProtocol(self, didReceive: URLResponse(), cacheStoragePolicy: .notAllowed)
      self.client?.urlProtocolDidFinishLoading(self)
    }
  }
  
  override func stopLoading() {
    
  }
}
