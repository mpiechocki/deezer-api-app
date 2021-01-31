import UIKit

class ControllerFactory: ControllerFactoring {

    func createController(for route: Route) -> UIViewController {
        let controller: UIViewController
        switch route {
        case .search:
            controller = SearchViewController(deezerService: deezerService)
        case .albums(let title, let artistId):
            controller = AlbumsViewController(title: title, artistId: artistId, deezerService: deezerService)
        case .albumDetails(let albumDetails):
            controller = AlbumDetailsViewController(albumDetails: albumDetails, deezerService: deezerService)
        }
        return controller
    }

    // MARK: - Private

    private let apiClient = APIClient(dataTaskProvider: URLSession.shared)
    private lazy var deezerService = DeezerService(apiClient: apiClient)

}
