import Combine

protocol DeezerServiceProtocol {
    func search(query: String) -> AnyPublisher<[Artist], APIError>
}
