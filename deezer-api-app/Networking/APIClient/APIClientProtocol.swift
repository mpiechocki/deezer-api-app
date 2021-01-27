import Combine

protocol APIClientProtocol {
    func perform(_ endpoint: APIEndpoint) -> AnyPublisher<SearchResult, APIError>
}
