import Combine
import Foundation

class APIClient: APIClientProtocol {

    init(dataTaskProvider: DataTaskProvider) {
        self.dataTaskProvider = dataTaskProvider
    }

    func perform(_ endpoint: APIEndpoint) -> AnyPublisher<SearchResult, APIError> {
        guard let url = endpoint.url else {
            return Fail<SearchResult, APIError>(error: APIError.urlError).eraseToAnyPublisher()
        }

        return dataTaskProvider.taskPublisher(for: url)
            .tryMap { element in
                guard let response = element.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw APIError.somethingWentWrong
                }

                return element.data
            }
            .decode(type: SearchResult.self, decoder: JSONDecoder())
            .mapError { _ in APIError.somethingWentWrong }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let dataTaskProvider: DataTaskProvider

}
