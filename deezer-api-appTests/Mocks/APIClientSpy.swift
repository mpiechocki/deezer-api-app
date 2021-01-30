import Combine
@testable import deezer_api_app

class APIClientSpy: APIClientProtocol {

    var performCalledWith = [APIEndpoint]()
    let stubbedPerformSubject = PassthroughSubject<Decodable, APIError>()

    // MARK: - APIClientProtocol

    func perform<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        performCalledWith.append(endpoint)

        return stubbedPerformSubject
            .map {
                $0 as! T
            }
            .eraseToAnyPublisher()
    }

}
