import Combine
import UIKit

protocol APIClientProtocol {
    func perform<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, APIError>
    func loadImage(url: String) -> AnyPublisher<UIImage?, APIError>
}
