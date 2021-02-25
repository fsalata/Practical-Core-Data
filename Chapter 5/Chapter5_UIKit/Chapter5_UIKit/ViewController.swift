import UIKit
import StorageProvider

class ViewController: UIViewController {
  let storageProvider: StorageProvider
  let datasource: ToDoItemDataSource

  lazy var generateButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.setTitle("Generate items", for: .normal)

    return btn
  }()

  lazy var loadButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.setTitle("Load items", for: .normal)

    return btn
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.dataSource = self
    return tableView
  }()

  init(storageProvider: StorageProvider) {
    self.storageProvider = storageProvider
    self.datasource = ToDoItemDataSource(persistentContainer: storageProvider.persistentContainer)

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let generateAction = UIAction(handler: { [weak self] _ in
      self?.datasource.generateAndInsertUsingBgContext()
      //self?.datasource.generateAndInsertUsingChildContext()
    })
    generateButton.addAction(generateAction, for: .touchUpInside)

    let loadAction = UIAction(handler: { [weak self] _ in
      self?.datasource.fetch {
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      }
    })
    loadButton.addAction(loadAction, for: .touchUpInside)

    let hStack = UIStackView(arrangedSubviews: [generateButton, loadButton])
    hStack.axis = .horizontal
    hStack.distribution = .equalCentering

    let vStack = UIStackView(arrangedSubviews: [hStack, tableView])
    vStack.axis = .vertical
    vStack.spacing = 16

    vStack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(vStack)

    NSLayoutConstraint.activate([
      vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      vStack.rightAnchor.constraint(equalTo: view.rightAnchor),
      vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      vStack.leftAnchor.constraint(equalTo: view.leftAnchor)
    ])
  }
}

extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datasource.numberOfItems
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let item = datasource.object(at: indexPath.row)
    cell.textLabel?.text = item?.title
    cell.textLabel?.numberOfLines = 0
    return cell
  }
}

