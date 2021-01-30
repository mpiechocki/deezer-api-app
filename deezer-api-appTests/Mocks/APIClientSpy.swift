import Combine
import UIKit
@testable import deezer_api_app

class APIClientSpy: APIClientProtocol {

    var performCalledWith = [APIEndpoint]()
    let stubbedPerformSubject = PassthroughSubject<Decodable, APIError>()
    var loadImageCalledWith = [String]()
    let stubbedLoadImageSubject = PassthroughSubject<UIImage?, APIError>()

    // MARK: - APIClientProtocol

    func perform<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        performCalledWith.append(endpoint)

        return stubbedPerformSubject
            .map {
                $0 as! T
            }
            .eraseToAnyPublisher()
    }

    func loadImage(url: String) -> AnyPublisher<UIImage?, APIError> {
        loadImageCalledWith.append(url)

        return stubbedLoadImageSubject.eraseToAnyPublisher()
    }

}
