import Combine
import XCTest
@testable import deezer_api_app

class DeezerServiceTests: XCTestCase {

    var apiClientSpy: APIClientSpy!
    var sut: DeezerService!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        apiClientSpy = APIClientSpy()
        sut = DeezerService(apiClient: apiClientSpy)

        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        apiClientSpy = nil
        cancellables = nil
        super.tearDown()
    }

    func test_search() {
        var caughtArtists = [[Artist]]()

        sut.search(query: "some query")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtArtists.append($0) }
            )
            .store(in: &cancellables)

        XCTAssertEqual(apiClientSpy.performCalledWith.count, 1)
        XCTAssertEqual(apiClientSpy.performCalledWith.first, APIEndpoint.search(query: "some query"))
        XCTAssertEqual(caughtArtists.count, 0)

        let searchResult = SearchResult(
            data: [.init(id: 1, name: "Metallica"), .init(id: 2, name: "Jade Bird"), .init(id: 3, name: "Slipknot")]
        )
        apiClientSpy.stubbedPerformSubject.send(searchResult)

        XCTAssertEqual(caughtArtists.count, 1)
        XCTAssertEqual(caughtArtists.first, searchResult.data)
    }

    func test_albums() {
        var caughtAlbums = [[Album]]()

        sut.albums(for: 243, fromIndex: 0)
            .sink(receiveCompletion: { _ in},
                  receiveValue: { caughtAlbums.append($0) }
            )
            .store(in: &cancellables)

        XCTAssertEqual(apiClientSpy.performCalledWith.count, 1)
        XCTAssertEqual(apiClientSpy.performCalledWith.first, APIEndpoint.albums(artistId: 243, index: 0))
        XCTAssertEqual(caughtAlbums.count, 0)

        let albumsResult = AlbumsResult(
            data: [.init(id: 1, title: "Life Is Peachy"), .init(id: 2, title: "Korn"), .init(id: 3, title: "Follow the leader")],
            total: 3,
            next: ""
        )
        apiClientSpy.stubbedPerformSubject.send(albumsResult)
        XCTAssertEqual(caughtAlbums.count, 1)
        XCTAssertEqual(caughtAlbums.first, albumsResult.data)
    }

}
