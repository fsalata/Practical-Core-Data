import StorageProvider
import Combine
import CoreData
import UIKit

class AlbumsOverviewViewController: UIViewController {

  let collectionView: UICollectionView

  let albumsProvider: AlbumsProvider
  let storageProvider: StorageProvider

  var cancellables = Set<AnyCancellable>()
  
  let cellRegistration =
    UICollectionView.CellRegistration<AlbumCell, Album> { cell, indexPath, album in
      cell.album = album
  }
  
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

    collectionView.dataSource = self
    collectionView.delegate = self
    
    albumsProvider.controllerDidChangePublisher
      .sink(receiveValue: { [weak self] updates in
        var movedToIndexPaths = [IndexPath]()
        
        self?.collectionView.performBatchUpdates({
          for update in updates {
            switch update {
            case let .section(sectionUpdate):
              switch sectionUpdate {
              case let .inserted(index):
                self?.collectionView.insertSections([index])
              case let .deleted(index):
                self?.collectionView.deleteSections([index])
              }
            case let .object(objectUpdate):
              switch objectUpdate {
              case let .inserted(at: indexPath):
                self?.collectionView.insertItems(at: [indexPath])
              case let .deleted(from: indexPath):
                self?.collectionView.deleteItems(at: [indexPath])
              case let .updated(at: indexPath):
                self?.collectionView.reloadItems(at: [indexPath])
              case let .moved(from: source, to: target):
                self?.collectionView.moveItem(at: source, to: target)
                movedToIndexPaths.append(target)
              }
            }
          }
        }, completion: { done in
          self?.collectionView.reloadItems(at: movedToIndexPaths)
        })
      })
      .store(in: &cancellables)
  }

  @objc func addAlbum() {
    let vc = AddAlbumViewController(storageProvider: storageProvider)
    let navVC = UINavigationController(rootViewController: vc)
    present(navVC, animated: true, completion: nil)
  }
}

extension AlbumsOverviewViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return albumsProvider.numberOfSections
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return albumsProvider.numberOfItemsInSection(section)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: albumsProvider.object(at: indexPath))
    
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
