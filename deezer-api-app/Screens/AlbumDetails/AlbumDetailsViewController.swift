import UIKit

class AlbumDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    init(albumDetails: AlbumDetails) {
        self.albumDetails = albumDetails
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    let albumDetails: AlbumDetails
    var tracks = [Track]() {
        didSet {
            albumDetailsView.tableView.reloadData()
        }
    }

    // MARK: - View

    private(set) lazy var albumDetailsView = AlbumDetailsView()

    override func loadView() {
        view = albumDetailsView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
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

    private func configureTableView() {
        albumDetailsView.tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseId)
        albumDetailsView.tableView.dataSource = self
        let albumHeader = AlbumHeader()
        albumHeader.imageView.image = UIImage(systemName: "lasso.sparkles")
        albumDetailsView.tableView.tableHeaderView = albumHeader
    }

}
