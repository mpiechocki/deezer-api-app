import UIKit

class ControllerFactory: ControllerFactoring {

    func createController(for route: Route) -> UIViewController {
        let controller: UIViewController
        switch route {
        case .search:
            controller = SearchViewController(deezerService: deezerService)
        case .albums(let artistId):
            controller = AlbumsViewController(artistId: artistId, deezerService: deezerService)
        }
        return controller
    }

    // MARK: - Private

    private let apiClient = APIClient(dataTaskProvider: URLSession.shared)
    private lazy var deezerService = DeezerService(apiClient: apiClient)

}
