import Combine

class DeezerService: DeezerServiceProtocol {

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - DeezerServiceProtocol

    func search(query: String) -> AnyPublisher<[Artist], APIError> {
        apiClient.perform(.search(query: query))
            .map { (result: SearchResult) -> [Artist] in result.data }
            .eraseToAnyPublisher()
    }

    func albums(for artistId: Int, fromIndex index: Int) -> AnyPublisher<AlbumsResult, APIError> {
        apiClient.perform(.albums(artistId: artistId, index: index))
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let apiClient: APIClientProtocol

}
