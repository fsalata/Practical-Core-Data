import StorageProvider
import Combine
import CoreData
import UIKit

class AlbumsOverviewViewController: UIViewController {

  let collectionView: UICollectionView
  var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!

  let albumsProvider: AlbumsProvider
  let storageProvider: StorageProvider

  var cancellables = Set<AnyCancellable>()
  
  static private(set) var layout: UICollectionViewCompositionalLayout = {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .estimated(101.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                   subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    return UICollectionViewCompositionalLayout(section: section)
  }()

  init(storageProvider: StorageProvider) {
    self.albumsProvider = AlbumsProvider(storageProvider: storageProvider)
    self.storageProvider = storageProvider

    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.layout)

    super.init(nibName: nil, bundle: nil)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                             target: self, action: #selector(addAlbum))

    self.navigationItem.title = "My Albums"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)
    collectionView.pinToEdges(of: view)

    view.backgroundColor = .systemBackground
    collectionView.backgroundColor = .systemBackground

    dataSource = makeDataSource()
    collectionView.dataSource = dataSource
    collectionView.delegate = self

    albumsProvider.$snapshot
      .sink(receiveValue: { [weak self] snapshot in
        if let snapshot = snapshot {
          self?.dataSource.apply(snapshot)
        }
      })
      .store(in: &cancellables)
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, NSManagedObjectID> {
    let cellRegistration =
      UICollectionView.CellRegistration<AlbumCell, NSManagedObjectID> { [weak self] cell, indexPath, albumID in
        guard let album = self?.albumsProvider.object(at: indexPath) else {
          return
        }
        
        cell.album = album
    }

    return UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(
      collectionView: collectionView, cellProvider: { collectionView, indexPath, album in
        collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                     for: indexPath,
                                                     item: album)
      })
  }

  @objc func addAlbum() {
    let vc = AddAlbumViewController(storageProvider: storageProvider)
    let navVC = UINavigationController(rootViewController: vc)
    present(navVC, animated: true, completion: nil)
  }
}

extension AlbumsOverviewViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)

    let vc = AlbumDetailViewController(album: albumsProvider.object(at: indexPath),
                                       storageProvider: storageProvider)

    navigationController?.pushViewController(vc, animated: true)
  }
}
