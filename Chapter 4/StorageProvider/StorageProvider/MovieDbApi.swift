import Foundation
import Combine

let apiKey = "<your-api-key>"

enum MovieDbAPI {
  class Session {
    let discover = DiscoverApi()
    let movie = MovieApi()
  }

  class DiscoverApi {
    let endpoint = URL(string: "https://api.themoviedb.org/3/discover/movie")!
    let decoder: JSONDecoder

    init() {
      decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    struct RequestParams {
      let sorting: String
      let page: Int
      let releasedBefore: String
    }

    struct DiscoverResponse: Decodable {
      let page: Int
      let totalResults: Int
      let totalPages: Int
      let results: [Movie]
    }

    func load(_ request: RequestParams) -> AnyPublisher<DiscoverResponse, Error> {
      let queryString = [
        "sorting": request.sorting,
        "page": "\(request.page)",
        "release_date.lte": request.releasedBefore,
        "api_key": apiKey
      ]

      guard var components = URLComponents(url: endpoint,
                                           resolvingAgainstBaseURL: false) else {
        fatalError("Misconfigured the endpoint URL, abort!")
      }

      components.queryItems = queryString.map({ (key, value) in
        return URLQueryItem(name: key, value: value)
      })

      guard let url = components.url else {
        fatalError("Misconfigured the query items, abort!")
      }

      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: DiscoverResponse.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
  }

  class MovieApi {
    let endpoint = URL(string: "https://api.themoviedb.org/3/movie/")!
    let decoder: JSONDecoder

    init() {
      decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func credits(_ movieId: Int) -> AnyPublisher<CreditResponse, Error> {
      let baseUrl = endpoint
        .appendingPathComponent("\(movieId)")
        .appendingPathComponent("credits")

      let queryString = [
        "api_key": apiKey
      ]

      guard var components = URLComponents(url: baseUrl,
                                           resolvingAgainstBaseURL: false) else {
        fatalError("Misconfigured the endpoint URL, abort!")
      }

      components.queryItems = queryString.map({ (key, value) in
        return URLQueryItem(name: key, value: value)
      })

      guard let url = components.url else {
        fatalError("Misconfigured the query items, abort!")
      }

      return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: CreditResponse.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
  }

  struct Movie: Decodable {
    let popularity: Double
    let id: Int
    let title: String
    let releaseDate: String
    let posterPath: String
    let overview: String
    var cast: [Credit]?
  }

  struct Credit: Decodable {
    let id: Int
    let character: String
    let name: String
    let castId: Int
  }

  struct CreditResponse: Decodable {
    let cast: [Credit]
  }
}
