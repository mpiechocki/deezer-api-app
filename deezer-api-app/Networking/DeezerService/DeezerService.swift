import Combine

class DeezerService: DeezerServiceProtocol {

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - DeezerServiceProtocol

    func search(query: String) -> AnyPublisher<[Artist], APIError> {
        apiClient.perform(.search(query: query))
            .map { $0.data }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let apiClient: APIClientProtocol

}
