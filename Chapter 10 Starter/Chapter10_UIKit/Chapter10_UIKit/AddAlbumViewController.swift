import CoreData
import UIKit
import StorageProvider
import PhotosUI

class AddAlbumViewController: UIViewController, UITextFieldDelegate {
  let storageProvider: StorageProvider

  let album: Album
  var artistName = ""

  let albumCover = UIImageView()

  let context: NSManagedObjectContext

  init(storageProvider: StorageProvider, album: Album? = nil) {
    self.storageProvider = storageProvider

    let context = storageProvider.childViewContext()
    if let objectID = album?.objectID, let existingAlbum = try? context.existingObject(with: objectID) as? Album {
      self.album = existingAlbum
    } else {
      self.album = Album(context: context)
    }
    self.context = context
    self.artistName = album?.artist.name ?? ""

    super.init(nibName: nil, bundle: nil)

    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                       target: self, action: #selector(cancel))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                        target: self, action: #selector(save))
    navigationItem.title = "Add New Album"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemGray6

    let infoHeader = UILabel()
    infoHeader.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    infoHeader.text = "ALBUM INFO"

    let artistField = UITextField()
    artistField.borderStyle = .roundedRect
    artistField.placeholder = "Artist name"
    artistField.text = artistName
    artistField.tag = 1
    artistField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    artistField.delegate = self

    let titleField = UITextField()
    titleField.borderStyle = .roundedRect
    titleField.placeholder = "Album title"
    titleField.text = album.title
    titleField.tag = 2
    titleField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    titleField.delegate = self

    let genreField = UITextField()
    genreField.borderStyle = .roundedRect
    genreField.placeholder = "Genre"
    genreField.text = album.genre
    genreField.tag = 3
    genreField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    genreField.delegate = self

    let releaseLabel = UILabel()
    releaseLabel.text = "Release date"

    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.date = album.releaseDate

    let releaseDateStack = UIStackView(arrangedSubviews: [releaseLabel, picker])
    releaseDateStack.axis = .horizontal
    releaseDateStack.spacing = 16

    let coverHeader = UILabel()
    coverHeader.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    coverHeader.text = "ALBUM COVER"

    albumCover.contentMode = .scaleAspectFill
    albumCover.clipsToBounds = true
    albumCover.layer.cornerRadius = 8
    albumCover.backgroundColor = .gray
    albumCover.image = album.albumCover
    albumCover.translatesAutoresizingMaskIntoConstraints = false

    let coverButton = UIButton(type: .system)
    coverButton.setTitle("Select cover", for: .normal)
    coverButton.addTarget(self, action: #selector(selectCoverImage), for: .touchUpInside)

    let albumStack = UIStackView(arrangedSubviews: [albumCover, coverButton])
    albumStack.axis = .horizontal
    albumStack.spacing = 16

    let scrollView = UIScrollView()
    view.addSubview(scrollView)
    scrollView.pinToEdges(of: view, useSafeArea: true, inset: 16)

    let vStack = UIStackView(arrangedSubviews: [
      infoHeader, artistField, titleField, genreField, releaseDateStack,
      coverHeader, albumStack
    ])
    vStack.axis = .vertical
    vStack.spacing = 8
    vStack.setCustomSpacing(16, after: infoHeader)
    vStack.setCustomSpacing(16, after: coverHeader)
    vStack.setCustomSpacing(32, after: releaseDateStack)

    scrollView.addSubview(vStack)
    vStack.pinToEdges(of: scrollView)
    vStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32).isActive = true
    albumCover.widthAnchor.constraint(equalToConstant: 85).isActive = true
    albumCover.heightAnchor.constraint(equalToConstant: 85).isActive = true
  }

  @objc func cancel() {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  @objc func save() {
    do {
      let artist = Artist.findOrInsert(using: artistName, in: context)
      album.artist = artist

      try context.save()
      try storageProvider.persistentContainer.viewContext.save()
      presentingViewController?.dismiss(animated: true, completion: nil)
    } catch {
      let alert = UIAlertController(title: "Something went wrong",
                                    message: "Make sure all fields are filled",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }

  @objc func textFieldDidChange(_ textField: UITextField) {
    switch textField.tag {
    case 1: artistName = textField.text ?? ""
    case 2: album.title = textField.text ?? ""
    case 3: album.genre = textField.text ?? ""
    default: break
    }
  }

  @objc func releaseDateChanged(_ picker: UIDatePicker) {
    album.releaseDate = picker.date
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  @objc func selectCoverImage() {
    var configuration = PHPickerConfiguration()
    configuration.selectionLimit = 1
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    present(picker, animated: true, completion: nil)
  }
}


extension AddAlbumViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
      result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
        if let error = error {
          print(error)
          return
        }

        DispatchQueue.main.async {
          self?.albumCover.image = image as? UIImage
          self?.album.albumCover = image as? UIImage
          self?.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
}
