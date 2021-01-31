import Combine
import UIKit

protocol DeezerServiceProtocol {
    func search(query: String) -> AnyPublisher<[Artist], APIError>
    func albums(for artistId: Int, fromIndex: Int) -> AnyPublisher<AlbumsResult, APIError>
    func image(path: String) -> AnyPublisher<UIImage?, APIError>
    func tracks(for albumId: Int, fromIndex: Int) -> AnyPublisher<TracksResult, APIError>
}
