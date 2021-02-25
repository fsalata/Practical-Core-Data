import UIKit
import StorageProvider

class AlbumCell: UICollectionViewCell {
  var album: Album? {
    didSet {
      update()
    }
  }
  
  private let imageView = UIImageView()
  private let artistLabel = UILabel()
  private let albumLabel = UILabel()
  private let lastSessionLabel = UILabel()
  
  override init(frame: CGRect) {
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 8
    imageView.clipsToBounds = true
    imageView.backgroundColor = .gray
    
    artistLabel.font = UIFont.boldSystemFont(ofSize: 16)
    lastSessionLabel.font = UIFont.systemFont(ofSize: 12)
    
    super.init(frame: .zero)
    
    let vStack = UIStackView(arrangedSubviews: [artistLabel, albumLabel, lastSessionLabel])
    vStack.axis = .vertical
    vStack.spacing = 4
    vStack.setCustomSpacing(8, after: albumLabel)
    
    let hStack = UIStackView(arrangedSubviews: [imageView, vStack])
    hStack.axis = .horizontal
    hStack.spacing = 16
    
    addSubview(hStack)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    hStack.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalToConstant: 85).isActive = true
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
    hStack.pinToEdges(of: self, inset: 8)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update() {
    guard let album = album else {
      return
    }
    
    imageView.image = album.albumCover
    artistLabel.text = album.artist.name
    albumLabel.text = album.title
    if let session = album.listeningSessions.first?.date {
      lastSessionLabel.text = "\(session)"
    } else {
      lastSessionLabel.text = "Not listened yet"
    }
  }
}
