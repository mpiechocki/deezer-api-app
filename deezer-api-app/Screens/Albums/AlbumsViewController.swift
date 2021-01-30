import Combine
import UIKit

class AlbumsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    init(artistId: Int, deezerService: DeezerServiceProtocol) {
        self.artistId = artistId
        self.deezerService = deezerService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    let artistId: Int

    var albums: [Album] = [] {
        didSet {
            albumsView.collectionView.reloadData()
        }
    }

    // MARK: - View

    private(set) lazy var albumsView = AlbumsView()

    override func loadView() {
        view = albumsView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        loadAlbums()
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
        cell.imageView.image = UIImage(systemName: "scribble")
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.bounds.size
        let cellWidth = (collectionViewSize.width / 2) - 4
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

    // MARK: - Private

    private let deezerService: DeezerServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private func configureCollectionView() {
        albumsView.collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.reuseId)
        albumsView.collectionView.dataSource = self
        albumsView.collectionView.delegate = self
    }

    private func loadAlbums() {
        deezerService.albums(for: artistId, fromIndex: 0)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { print($0) },
                receiveValue: { [weak self] in self?.albums = $0 }
            )
            .store(in: &cancellables)
    }

}
