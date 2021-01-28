import XCTest
import Combine
@testable import deezer_api_app

class APIClientTests: XCTestCase {

    var dataTaskProviderSpy: DataTaskProviderSpy!
    var sut: APIClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        dataTaskProviderSpy = DataTaskProviderSpy()
        sut = APIClient(dataTaskProvider: dataTaskProviderSpy)

        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        dataTaskProviderSpy = nil
        cancellables = nil
    }

    func test_perform_search_success() throws {
        var caughtSearchResult: SearchResult?

        sut.perform(.search(query: "someartist"))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtSearchResult = $0 }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/search/artist?q=someartist")

        let bundle = Bundle(for: type(of:self))
        let resultPath = bundle.path(forResource: "search_result", ofType: "json")!
        let contentsData = try String(contentsOfFile: resultPath).data(using: .utf8)!

        let response = HTTPURLResponse.success
        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: response))
        XCTAssertEqual(caughtSearchResult?.data.count, 3)

        let expectedArtistsNames = [
            "Fleetwood Mac",
            "Peter Green's Fleetwood Mac",
            "Fleetwood Mac & The Christine Perfect Band"
        ]

        let actualArtistsNames = caughtSearchResult?.data.map { $0.name }
        XCTAssertEqual(actualArtistsNames, expectedArtistsNames)

        let expectedIds: [UInt] = [169, 67268272, 5862296]
        let actualIds = caughtSearchResult?.data.map { $0.id }
        XCTAssertEqual(actualIds, expectedIds)
    }

    func test_perform_decoding_failure() throws {
        var caughtError: Error?

        sut.perform(.search(query: "someartist"))
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { (_: AlbumsResult) -> Void in }
            )
            .store(in: &cancellables)

        let bundle = Bundle(for: type(of:self))
        let resultPath = bundle.path(forResource: "broken_search_results", ofType: "json")!
        let contentsData = try String(contentsOfFile: resultPath).data(using: .utf8)!

        let response = HTTPURLResponse.success
        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: response))

        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
    }

    func test_perform_url_failure() {
        var caughtError: Error?

        sut.perform(.albums(artistId: 0))
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { (_: AlbumsResult) -> Void in }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/artist/0/albums")

        let response = HTTPURLResponse.forbidden
        dataTaskProviderSpy.stubbedTaskSubject.send((data: Data(), response: response))
        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
    }

    func test_perform_session_failure() {
        var caughtError: Error?

        sut.perform(.albums(artistId: 0))
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { (_: AlbumsResult) -> Void in }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/artist/0/albums")

        dataTaskProviderSpy.stubbedTaskSubject.send(completion: .failure(URLError(.cannotFindHost)))
        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
    }

    func test_perform_albums() throws {
        var caughtAlbumsResult: AlbumsResult?

        sut.perform(.albums(artistId: 1872))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtAlbumsResult = $0 }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/artist/1872/albums")

        let bundle = Bundle(for: type(of:self))
        let resultPath = bundle.path(forResource: "albums_result", ofType: "json")!
        let contentsData = try String(contentsOfFile: resultPath).data(using: .utf8)!

        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: HTTPURLResponse.success))
        XCTAssertEqual(caughtAlbumsResult?.data.count, 3)

        let expectedAlbums: [Album] = [
            .init(id: 194219042, title: "Music To Be Murdered By - Side B (Deluxe Edition)"),
            .init(id: 127270232, title: "Music To Be Murdered By"),
            .init(id: 72000342, title: "Kamikaze")
        ]

        let actualAlbums = caughtAlbumsResult?.data
        XCTAssertEqual(actualAlbums, expectedAlbums)
    }

}

extension HTTPURLResponse {

    static var success: HTTPURLResponse {
        HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    static var forbidden: HTTPURLResponse {
        HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 403, httpVersion: nil, headerFields: nil)!
    }

}
