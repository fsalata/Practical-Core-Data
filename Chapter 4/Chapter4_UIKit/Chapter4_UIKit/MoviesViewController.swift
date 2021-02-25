import UIKit
import StorageProvider
import CoreData
import Combine

class MoviesViewController: UIViewController {

  let collectionView: UICollectionView
  var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!

  let moviesProvider: MoviesProvider

  var cancellables = Set<AnyCancellable>()

  init(storageProvider: StorageProvider) {
    self.moviesProvider = MoviesProvider(storageProvider: storageProvider)

    let config = UICollectionLayoutListConfiguration(appearance: .plain)
    let layout = UICollectionViewCompositionalLayout.list(using: config)
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    super.init(nibName: nil, bundle: nil)

    self.tabBarItem = UITabBarItem(title: "Movies",
                                   image: UIImage(systemName: "film"),
                                   selectedImage: UIImage(systemName: "film.fill"))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.allowsSelection = false

    view.backgroundColor = .systemBackground
    collectionView.backgroundColor = .systemBackground

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
    ])

    dataSource = makeDataSource()
    collectionView.dataSource = dataSource

    moviesProvider.$snapshot
      .sink(receiveValue: { [weak self] snapshot in
        if let snapshot = snapshot {
          self?.dataSource.apply(snapshot)
        }
      })
      .store(in: &cancellables)
  }
}

extension MoviesViewController {
  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, NSManagedObjectID> {
    let cellRegistration =
      UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { [weak self] cell, indexPath, movieId in
        guard let movie = self?.moviesProvider.object(at: indexPath) else {
          return
        }

        var config = cell.defaultContentConfiguration()
        config.text = movie.title
        cell.contentConfiguration = config
    }

    return UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(
      collectionView: collectionView, cellProvider: { collectionView, indexPath, movie in
        collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                     for: indexPath,
                                                     item: movie)
      })
  }
}
