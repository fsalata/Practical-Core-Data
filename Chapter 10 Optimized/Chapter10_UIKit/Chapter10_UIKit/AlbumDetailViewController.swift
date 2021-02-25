import StorageProvider
import UIKit
import CoreData

class AlbumDetailViewController: UIViewController {
  let album: Album
  let storageProvider: StorageProvider

  let artistButton = UIButton(type: .system)
  let titleLabel = UILabel()
  let genreLabel = UILabel()
  let releaseLabel = UILabel()
  let notesList: UICollectionView

  static let formatter = ISO8601DateFormatter()

  init(album: Album, storageProvider: StorageProvider) {
    self.album = album
    self.storageProvider = storageProvider

    let config = UICollectionLayoutListConfiguration(appearance: .plain)
    let layout = UICollectionViewCompositionalLayout.list(using: config)
    self.notesList = UICollectionView(frame: .zero, collectionViewLayout: layout)
    notesList.backgroundColor = .systemBackground
    notesList.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "NoteCell")
    notesList.allowsSelection = false

    super.init(nibName: nil, bundle: nil)

    notesList.dataSource = self

    navigationItem.title = album.title
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAlbum))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(_:)),
                                           name: NSManagedObjectContext.didSaveObjectIDsNotification,
                                           object: storageProvider.persistentContainer.viewContext)

    view.backgroundColor = .systemBackground

    artistButton.addTarget(self, action: #selector(navigateToArtist), for: .touchUpInside)
    artistButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21)

    titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

    let genrePrefix = UILabel()
    genrePrefix.font = UIFont.boldSystemFont(ofSize: 16)
    genrePrefix.text = "Genre:"

    let genreStack = UIStackView(arrangedSubviews: [genrePrefix, genreLabel])
    genreStack.axis = .horizontal
    genreStack.alignment = .leading

    let releasePrefix = UILabel()
    releasePrefix.font = UIFont.boldSystemFont(ofSize: 16)
    releasePrefix.text = "Released:"

    let releaseStack = UIStackView(arrangedSubviews: [releasePrefix, releaseLabel])
    releaseStack.axis = .horizontal
    releaseStack.alignment = .leading

    let notesHeader = UILabel()
    notesHeader.font = UIFont.boldSystemFont(ofSize: 16)
    notesHeader.text = "Notes"

    let addNoteButton = UIButton(type: .system)
    addNoteButton.setTitle("Add", for: .normal)
    addNoteButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)

    let notesStack = UIStackView(arrangedSubviews: [notesHeader, addNoteButton])
    notesStack.axis = .horizontal
    notesStack.spacing = 8

    let vStack = UIStackView(arrangedSubviews: [artistButton, titleLabel, genreStack, releaseStack, notesStack])
    vStack.axis = .vertical
    vStack.alignment = .leading
    vStack.spacing = 8
    vStack.setCustomSpacing(32, after: titleLabel)
    vStack.setCustomSpacing(16, after: releaseStack)

    view.addSubview(vStack)
    vStack.translatesAutoresizingMaskIntoConstraints = false
    vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    vStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
    vStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 8).isActive = true

    view.addSubview(notesList)
    notesList.translatesAutoresizingMaskIntoConstraints = false
    notesList.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 8).isActive = true
    notesList.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    notesList.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    notesList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

    updateUI()
  }

  func updateUI() {
    artistButton.setTitle(album.artist.name, for: .normal)
    titleLabel.text = album.title
    genreLabel.text = album.genre
    releaseLabel.text = Self.formatter.string(from: album.releaseDate)
    notesList.reloadData()
  }

  @objc func editAlbum() {
    let vc = AddAlbumViewController(storageProvider: storageProvider, album: album)
    let navVC = UINavigationController(rootViewController: vc)
    present(navVC, animated: true, completion: nil)
  }

  @objc func navigateToArtist() {}

  @objc func addNote() {
    let vc = AddNoteViewController(album: album, storageProvider: storageProvider)
    let navVC = UINavigationController(rootViewController: vc)
    present(navVC, animated: true, completion: nil)
  }

  @objc func managedObjectContextDidSave(_ notification: Notification) {
    if let objectIDs = notification.updatedObjectIDs,
       objectIDs.contains(album.objectID) {
      updateUI()
    }
  }
}

extension AlbumDetailViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    album.sortedSessions.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell",
                                                  for: indexPath) as! UICollectionViewListCell

    let session = album.sortedSessions[indexPath.row]
    var config = cell.defaultContentConfiguration()
    config.text = session.notes
    cell.contentConfiguration = config

    return cell
  }
}

extension Dictionary where Key == AnyHashable {
  func value<T>(for key: NSManagedObjectContext.NotificationKey) -> T? {
    return self[key.rawValue] as? T
  }
}

extension Notification {
  var updatedObjectIDs: Set<NSManagedObjectID>? {
    return userInfo?.value(for: .updatedObjectIDs)
  }
}
