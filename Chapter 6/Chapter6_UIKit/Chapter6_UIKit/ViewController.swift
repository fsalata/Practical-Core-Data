import UIKit
import StorageProvider
import CoreData

class ViewController: UIViewController {

  let storageProvider: StorageProvider
  let fetchedResultsController: NSFetchedResultsController<ToDoItem>
  var _view: View!
  var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
  var dataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID>!

  init(storageProvider: StorageProvider) {
    self.storageProvider = storageProvider

    let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ToDoItem.dueDate, ascending: true)]

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                          managedObjectContext: storageProvider.persistentContainer.viewContext,
                                                          sectionNameKeyPath: nil, cacheName: nil)

    super.init(nibName: nil, bundle: nil)

    fetchedResultsController.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    _view = View()
    self.view = _view
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = UITableViewDiffableDataSource(tableView: _view.tableView) { [unowned self] tableView, indexPath, _ in
      let item = self.fetchedResultsController.object(at: indexPath)
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      cell.textLabel?.text = item.title

      return cell
    }

    _view.tableView.dataSource = dataSource

    _view.addButton.addAction(UIAction(handler: { [unowned self] _ in
                                        self.storageProvider.generateAndInsertObjects() }), for: .touchUpInside)
    _view.deleteButton.addAction(UIAction(handler: { [unowned self] _ in storageProvider.deleteAllObjects() }), for: .touchUpInside)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    try? fetchedResultsController.performFetch()
  }
}

extension ViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
      var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

      let idsToReload = newSnapshot.itemIdentifiers.filter({ identifier in
        // check if this identifier is in the old snapshot
        // and that it didn't move to a new position
        guard let oldIndex = self.snapshot?.indexOfItem(identifier),
              let newIndex = newSnapshot.indexOfItem(identifier),
              oldIndex == newIndex else {
          return false
        }

        // check if we need to update this object
        guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else {
          return false
        }

        return true
      })

      newSnapshot.reloadItems(idsToReload)

      self.snapshot = newSnapshot
      dataSource.apply(newSnapshot)
    }
}

extension ViewController {
  class View: UIView {
    let tableView: UITableView
    let addButton: UIButton
    let deleteButton: UIButton

    init() {
      tableView = UITableView()
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

      addButton = UIButton(type: .system)
      addButton.setTitle("Insert items", for: .normal)

      deleteButton = UIButton(type: .system)
      deleteButton.setTitle("Delete all", for: .normal)
      deleteButton.role = .destructive
      deleteButton.setTitleColor(.red, for: .normal)

      super.init(frame: .zero)

      addSubview(tableView)
      addSubview(addButton)
      addSubview(deleteButton)

      setupLayout()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
      backgroundColor = .systemBackground

      let hStack = UIStackView(arrangedSubviews: [addButton, deleteButton])
      hStack.axis = .horizontal
      hStack.alignment = .center
      hStack.distribution = .fillEqually

      let vStack = UIStackView(arrangedSubviews: [hStack, tableView])
      vStack.axis = .vertical
      vStack.spacing = 0

      addSubview(vStack)

      vStack.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        vStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        vStack.rightAnchor.constraint(equalTo: rightAnchor),
        vStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        vStack.leftAnchor.constraint(equalTo: leftAnchor)
      ])
    }
  }
}
