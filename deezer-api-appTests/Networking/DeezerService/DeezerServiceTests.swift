import Combine
import XCTest
@testable import deezer_api_app

class DeezerServiceTests: XCTestCase {

    var apiClientSpy: APIClientSpy!
    var sut: DeezerService!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        apiClientSpy = APIClientSpy()
        sut = DeezerService(apiClient: apiClientSpy)

        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        apiClientSpy = nil
        cancellables = nil
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

        let searchResult = SearchResult(
            data: [.init(id: 1, name: "Metallica"), .init(id: 2, name: "Jade Bird"), .init(id: 3, name: "Slipknot")]
        )
        apiClientSpy.stubbedPerformSubject.send(searchResult)

        XCTAssertEqual(caughtArtists.count, 1)
        XCTAssertEqual(caughtArtists.first, searchResult.data)
    }

}
