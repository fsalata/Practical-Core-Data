import UIKit
import StorageProvider

class MoviesViewController: UIViewController {

  let storageProvider: StorageProvider

  let newMovieLabel: UILabel = {
    let lbl = UILabel()
    lbl.text = "Add new movie"
    lbl.font = .preferredFont(forTextStyle: .title1)
    return lbl
  }()

  let addMovieTextField: UITextField = {
    let txt = UITextField()
    txt.placeholder = "Movie name"
    return txt
  }()

  lazy var saveMovieButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.setTitle("Save movie", for: .normal)

    return btn
  }()

  var movies = [Movie]() {
    didSet {
      self.tableView.reloadData()
    }
  }

  lazy var loadMoviesButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.setTitle("Fetch all movies", for: .normal)

    return btn
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.dataSource = self
    tableView.delegate = self
    return tableView
  }()

  init(storageProvider: StorageProvider) {
    self.storageProvider = storageProvider

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let saveAction = UIAction(handler: { [weak self] _ in
      self?.storageProvider.saveMovie(named: self?.addMovieTextField.text ?? "")
      self?.addMovieTextField.text = ""
    })
    saveMovieButton.addAction(saveAction, for: .touchUpInside)

    let loadMoviesAction = UIAction(handler: { [weak self] _ in
      self?.movies = self?.storageProvider.getAllMovies() ?? []
    })
    loadMoviesButton.addAction(loadMoviesAction, for: .touchUpInside)

    let hStack = UIStackView(arrangedSubviews: [saveMovieButton, loadMoviesButton])
    hStack.axis = .horizontal
    hStack.distribution = .equalCentering

    let vStack = UIStackView(arrangedSubviews: [newMovieLabel, addMovieTextField, hStack, tableView])
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

extension MoviesViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = movies[indexPath.row].name ?? "no name"
    return cell
  }
}

extension MoviesViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else {
      return
    }

    let movie = movies[indexPath.row]
    storageProvider.deleteMovie(movie)
    movies.remove(at: indexPath.row)
  }
}

