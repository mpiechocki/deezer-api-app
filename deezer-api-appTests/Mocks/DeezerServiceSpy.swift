import Combine
@testable import deezer_api_app

class DeezerServiceSpy: DeezerServiceProtocol {

    var searchCalledWith = [String]()
    var stubbedSearchSubject = PassthroughSubject<[Artist], APIError>()
    var albumsCalledWith = [Int]()
    var stubbedAlbumsSubject = PassthroughSubject<[Album], APIError>()

    // MARK: - DeezerServiceProtocol

    func search(query: String) -> AnyPublisher<[Artist], APIError> {
        searchCalledWith.append(query)

        return stubbedSearchSubject.eraseToAnyPublisher()
    }

    func albums(for artistId: Int) -> AnyPublisher<[Album], APIError> {
        albumsCalledWith.append(artistId)

        return stubbedAlbumsSubject.eraseToAnyPublisher()
    }

}
