import UIKit
import CoreData
import StorageProvider

class AddNoteViewController: UIViewController {
  let storageProvider: StorageProvider
  let context: NSManagedObjectContext
  let note: ListeningSession

  init(album: Album, storageProvider: StorageProvider) {
    self.storageProvider = storageProvider
    self.context = storageProvider.childViewContext()

    self.note = ListeningSession(context: context)
    note.date = Date()
    note.album = try! context.existingObject(with: album.objectID) as! Album

    super.init(nibName: nil, bundle: nil)

    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                       target: self, action: #selector(cancel))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                        target: self, action: #selector(save))
    navigationItem.title = "Add Note"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemGray6

    let textView = UITextView()
    textView.delegate = self

    view.addSubview(textView)

    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
  }

  @objc func cancel() {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  @objc func save() {
    do {
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
}

extension AddNoteViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    note.notes = textView.text
  }
}
