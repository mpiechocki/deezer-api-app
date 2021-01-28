import Combine
import Foundation

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
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in APIError.somethingWentWrong }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let dataTaskProvider: DataTaskProvider

}
