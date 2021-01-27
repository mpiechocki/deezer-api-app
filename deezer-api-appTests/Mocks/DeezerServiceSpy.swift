import Combine
@testable import deezer_api_app

class DeezerServiceSpy: DeezerServiceProtocol {

    var searchCalledWith = [String]()
    var stubbedSearchSubject = PassthroughSubject<[Artist], APIError>()

    // MARK: - DeezerServiceProtocol

    func search(query: String) -> AnyPublisher<[Artist], APIError> {
        searchCalledWith.append(query)

        return stubbedSearchSubject.eraseToAnyPublisher()
    }

}
