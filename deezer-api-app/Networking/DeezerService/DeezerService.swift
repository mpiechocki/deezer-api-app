import Combine
import UIKit

class DeezerService: DeezerServiceProtocol {

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - DeezerServiceProtocol

    func search(query: String) -> AnyPublisher<[Artist], APIError> {
        guard !query.isEmpty else {
            return Just([Artist]())
                .mapError { _ in APIError.somethingWentWrong }
                .eraseToAnyPublisher()
        }

        return apiClient.perform(.search(query: query))
            .map { (result: SearchResult) -> [Artist] in result.data }
            .eraseToAnyPublisher()
    }

    func albums(for artistId: Int, fromIndex index: Int) -> AnyPublisher<AlbumsResult, APIError> {
        apiClient.perform(.albums(artistId: artistId, index: index))
            .eraseToAnyPublisher()
    }

    func image(path: String) -> AnyPublisher<UIImage?, APIError> {
        apiClient.loadImage(url: path)
    }

    func tracks(for albumId: Int, fromIndex index: Int) -> AnyPublisher<TracksResult, APIError> {
        apiClient.perform(.tracks(albumId: albumId, index: index))
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let apiClient: APIClientProtocol

}
