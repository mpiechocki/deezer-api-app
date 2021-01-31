import Combine
import UIKit

class AlbumDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    init(albumDetails: AlbumDetails, deezerService: DeezerServiceProtocol) {
        self.albumDetails = albumDetails
        self.deezerService = deezerService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    let albumDetails: AlbumDetails
    var tracks = [Track]() {
        didSet {
            albumDetailsView.tableView.reloadData()
        }
    }
    var totalTracks = 0

    // MARK: - View

    private(set) lazy var albumDetailsView = AlbumDetailsView()

    override func loadView() {
        view = albumDetailsView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadCover()
        loadTracks(fromIndex: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        albumDetailsView.tableView.tableHeaderView?.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: albumDetailsView.tableView.bounds.width * 0.5))
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as? TrackCell else {
            return UITableViewCell()
        }

        let track = tracks[indexPath.row]
        cell.numberLabel.text = "\(track.trackPosition)."
        cell.titleLabel.text = track.title
        cell.durationLabel.text = "\(track.duration)"
        return cell
    }

    // MARK: - Private

    private let deezerService: DeezerServiceProtocol
    private lazy var albumHeader = AlbumHeader()
    private var cancellables = Set<AnyCancellable>()

    private func configureTableView() {
        albumDetailsView.tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseId)
        albumDetailsView.tableView.dataSource = self
        albumDetailsView.tableView.tableHeaderView = albumHeader
    }

    private func loadCover() {
        deezerService.image(path: albumDetails.coverPath)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.albumHeader.imageView.image = $0
                }
            )
            .store(in: &cancellables)
    }

    private func loadTracks(fromIndex index: Int) {
        deezerService.tracks(for: albumDetails.albumId, fromIndex: index)
            .first()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                    self?.tracks += $0.data
                    self?.totalTracks = $0.total
                  }
            )
            .store(in: &cancellables)
    }

}
