import Combine
import UIKit

class AlbumsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    init(title: String, artistId: Int, deezerService: DeezerServiceProtocol) {
        self.artistId = artistId
        self.deezerService = deezerService
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { nil }

    let artistId: Int

    var albums: [Album] = [] {
        didSet {
            albumsView.collectionView.reloadData()
        }
    }
    var totalAlbums = 0

    // MARK: - View

    private(set) lazy var albumsView = AlbumsView()

    override func loadView() {
        view = albumsView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        loadAlbums(fromIndex: 0)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albums.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.reuseId, for: indexPath) as? AlbumCell else {
            return UICollectionViewCell()
        }

        let album = albums[indexPath.row]
        cell.titleLabel.text = album.title
        deezerService.image(path: album.coverMedium)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    cell.imageView.image = $0
                    cell.imageView.alpha = 1.0
                }
            )
            .store(in: &cell.cancellables)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.bounds.size
        let cellWidth = (collectionViewSize.width / 2) - 12
        let cellHeight = cellWidth * 1.1
        return .init(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row == albums.count - 1, albums.count < totalAlbums else { return }
        loadAlbums(fromIndex: albums.count)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        Environment.navigation.go(
            to: .albumDetails(
                albumDetails: .init(
                    name: album.title,
                    albumId: album.id,
                    coverPath: album.coverXl
                )
            )
        )
    }

    // MARK: - Private

    private let deezerService: DeezerServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private func configureCollectionView() {
        albumsView.collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.reuseId)
        albumsView.collectionView.dataSource = self
        albumsView.collectionView.delegate = self
    }

    private func loadAlbums(fromIndex: Int) {
        deezerService.albums(for: artistId, fromIndex: fromIndex)
            .first()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in self?.handleCompletion() },
                receiveValue: { [weak self] in
                    self?.albums += $0.data
                    self?.totalAlbums = $0.total
                }
            )
            .store(in: &cancellables)
    }

    private func handleCompletion() { /* TODO */ }

}
