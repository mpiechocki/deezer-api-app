import Combine
import Foundation
import UIKit

class APIClient: APIClientProtocol {

    init(dataTaskProvider: DataTaskProvider) {
        self.dataTaskProvider = dataTaskProvider
    }

    func perform<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, APIError> {
        guard let url = endpoint.url else {
            return Fail<T, APIError>(error: APIError.somethingWentWrong).eraseToAnyPublisher()
        }

        return dataTaskProvider.taskPublisher(for: url)
            .tryMap { element in
                guard let response = element.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw APIError.somethingWentWrong
                }

                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder.withConverFromSnakeCaseStategy)
            .mapError { _ in APIError.somethingWentWrong }
            .eraseToAnyPublisher()
    }

    func loadImage(url: String) -> AnyPublisher<UIImage?, APIError> {
        guard let url = URL(string: url) else {
            return Fail<UIImage?, APIError>(error: APIError.somethingWentWrong).eraseToAnyPublisher()
        }

        return dataTaskProvider.taskPublisher(for: url)
            .tryMap { (element: (data: Data, response: URLResponse)) -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw APIError.somethingWentWrong
                }

                return element.data
            }
            .map { UIImage(data: $0) }
            .mapError { _ in APIError.somethingWentWrong }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let dataTaskProvider: DataTaskProvider

}

extension JSONDecoder {

    static var withConverFromSnakeCaseStategy: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

}
