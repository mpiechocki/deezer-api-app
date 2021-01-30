import Combine

protocol DeezerServiceProtocol {
    func search(query: String) -> AnyPublisher<[Artist], APIError>
    func albums(for artistId: Int, fromIndex: Int) -> AnyPublisher<[Album], APIError>
}
