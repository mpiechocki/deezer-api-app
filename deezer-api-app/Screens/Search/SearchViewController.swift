import Combine
import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    init(deezerService: DeezerServiceProtocol) {
        self.deezerService = deezerService
        super.init(nibName: nil, bundle: nil)
        self.title = "Search"
    }

    required init?(coder: NSCoder) { nil }

    var artists: [Artist] = [] {
        didSet { searchView.tableView.reloadData() }
    }

    // MARK: - View

    private(set) lazy var searchView = SearchView()

    override func loadView() {
        view = searchView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureTableView()
        setupBindings()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let artist = artists[indexPath.row]
        cell.textLabel?.text = artist.name
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = artists[indexPath.row]
        Environment.navigation.go(to: .albums(title: artist.name, artistId: artist.id))
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Private

    private let deezerService: DeezerServiceProtocol
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    private func configureSearchBar() {
        searchView.searchBar.placeholder = "Artist's name"
        searchView.searchBar.delegate = self
    }

    private func configureTableView() {
        searchView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.tableFooterView = UIView()
    }

    private func setupBindings() {
        searchTextSubject
            .throttle(for: 1, scheduler: DispatchQueue.main, latest: true)
            .flatMap(maxPublishers: .max(1)) { [deezerService] query in
                deezerService.search(query: query)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.handleError()
                    }
                },
                receiveValue: { [weak self] in self?.artists = $0 }
            )
            .store(in: &cancellables)
    }

    private func handleError() {
        present(.errorAlert, animated: true)
    }

}

