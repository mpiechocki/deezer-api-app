import Combine
@testable import deezer_api_app

class DeezerServiceSpy: DeezerServiceProtocol {

    var searchCalledWith = [String]()
    var stubbedSearchSubject = PassthroughSubject<[Artist], APIError>()
    var albumsCalledWith = [(artistId: Int, index: Int)]()
    var stubbedAlbumsSubject = PassthroughSubject<AlbumsResult, APIError>()

    // MARK: - DeezerServiceProtocol

    func search(query: String) -> AnyPublisher<[Artist], APIError> {
        searchCalledWith.append(query)

        return stubbedSearchSubject.eraseToAnyPublisher()
    }

    func albums(for artistId: Int, fromIndex index: Int) -> AnyPublisher<AlbumsResult, APIError> {
        albumsCalledWith.append((artistId, index))

        return stubbedAlbumsSubject.eraseToAnyPublisher()
    }

}
