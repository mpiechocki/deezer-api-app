import Combine

protocol APIClientProtocol {
    func perform<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, APIError>
}
