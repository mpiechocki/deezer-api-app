import Combine
@testable import deezer_api_app

class APIClientSpy: APIClientProtocol {

    var performCalledWith = [APIEndpoint]()
    let stubbedPerformSubject = PassthroughSubject<SearchResult, APIError>()

    // MARK: - APIClientProtocol

    func perform(_ endpoint: APIEndpoint) -> AnyPublisher<SearchResult, APIError> {
        performCalledWith.append(endpoint)

        return stubbedPerformSubject.eraseToAnyPublisher()
    }

}
