import Combine
import Foundation

class APIClient {

    init(dataTaskProvider: DataTaskProvider) {
        self.dataTaskProvider = dataTaskProvider
    }

    func perform() -> AnyPublisher<String, APIError> {
        let url = URL(string: "https://api.deezer.com/search/artist?q=kygo")!

        return dataTaskProvider.taskPublisher(for: url)
            .tryMap { element in
                guard let response = element.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw APIError.somethingWentWrong
                }

                return "response"
            }
            .mapError { _ in APIError.somethingWentWrong }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private let dataTaskProvider: DataTaskProvider
    private var cancellables = Set<AnyCancellable>()

}
