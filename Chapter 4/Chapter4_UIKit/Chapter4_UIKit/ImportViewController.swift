import UIKit
import StorageProvider
import Combine

class ImportViewController: UIViewController {
  let storageProvider: StorageProvider

  var cancellables = Set<AnyCancellable>()

  init(storageProvider: StorageProvider) {
    self.storageProvider = storageProvider

    super.init(nibName: nil, bundle: nil)

    self.tabBarItem = UITabBarItem(title: "Import",
                                   image: UIImage(systemName: "icloud.and.arrow.down"),
                                   selectedImage: UIImage(systemName: "icloud.and.arrow.down.fill"))
  }

  override func viewDidLoad() {
    let button = UIButton(type: .system)

    button.addAction(UIAction(handler: { [weak self] _ in
      guard let self = self else { return }

      let importer = MovieDbImporter()
      importer.importNextPage(in: self.storageProvider.persistentContainer.viewContext)
        .sink(receiveCompletion: { completion in
          print(completion)
        }, receiveValue: { _ in
          print("done")
        })
        .store(in: &self.cancellables)
    }), for: .touchUpInside)

    button.setTitle("Run importer", for: .normal)

    button.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(button)

    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    view.backgroundColor = .systemBackground
  }
}
