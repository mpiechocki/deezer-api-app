import XCTest
import Combine
@testable import deezer_api_app

class APIClientTests: XCTestCase {

    var dataTaskProviderSpy: DataTaskProviderSpy!
    var sut: APIClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        dataTaskProviderSpy = DataTaskProviderSpy()
        sut = APIClient(dataTaskProvider: dataTaskProviderSpy)

        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        dataTaskProviderSpy = nil
        cancellables = nil
        super.tearDown()
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

        let expectedIds: [Int] = [169, 67268272, 5862296]
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

        sut.perform(.albums(artistId: 0, index: 0))
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
        XCTAssertEqual(urlString, "https://api.deezer.com/artist/0/albums?index=0")

        let response = HTTPURLResponse.forbidden
        dataTaskProviderSpy.stubbedTaskSubject.send((data: Data(), response: response))
        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
    }

    func test_perform_session_failure() {
        var caughtError: Error?

        sut.perform(.albums(artistId: 0, index: 0))
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
        XCTAssertEqual(urlString, "https://api.deezer.com/artist/0/albums?index=0")

        dataTaskProviderSpy.stubbedTaskSubject.send(completion: .failure(URLError(.cannotFindHost)))
        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
    }

    func test_perform_albums() throws {
        var caughtAlbumsResult: AlbumsResult?

        sut.perform(.albums(artistId: 1872, index: 0))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtAlbumsResult = $0 }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/artist/1872/albums?index=0")

        let bundle = Bundle(for: type(of:self))
        let resultPath = bundle.path(forResource: "albums_result", ofType: "json")!
        let contentsData = try String(contentsOfFile: resultPath).data(using: .utf8)!

        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: HTTPURLResponse.success))
        XCTAssertEqual(caughtAlbumsResult?.data.count, 3)

        let expectedAlbums: [Album] = .realAlbums

        let actualAlbums = caughtAlbumsResult?.data
        XCTAssertEqual(actualAlbums, expectedAlbums)
    }

    func test_loadImage() {
        var caughtImage: UIImage?

        sut.loadImage(url: "http://url.to/image.jpg")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtImage = $0 }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)
        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "http://url.to/image.jpg")

        let bundle = Bundle(for: type(of:self))
        let imagePath = bundle.path(forResource: "daftpunk", ofType: "jpg")!
        let contentsData = UIImage(contentsOfFile: imagePath)!.jpegData(compressionQuality: 1.0)!

        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: HTTPURLResponse.success))
        XCTAssertNotNil(caughtImage)
    }

    func test_loadImageUndecodable() throws {
        var caughtImage: UIImage?

        sut.loadImage(url: "http://url.to/image.jpg")
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtImage = $0 }
            )
            .store(in: &cancellables)

        let bundle = Bundle(for: type(of:self))
        let imagePath = bundle.path(forResource: "albums_result", ofType: "json")!
        let contentsData = try String(contentsOfFile: imagePath).data(using: .utf8)!

        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: HTTPURLResponse.success))
        XCTAssertNil(caughtImage)
    }

    func test_loadImageFailure() {
        var caughtError: APIError?

        sut.loadImage(url: "http://url.to/image.jpg")
            .sink(
                receiveCompletion: {
                    if case let .failure(error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        dataTaskProviderSpy.stubbedTaskSubject.send((data: Data(), response: HTTPURLResponse.forbidden))
        XCTAssertEqual(caughtError, .somethingWentWrong)
    }

    func test_loadImageBadURL() {
        var caughtError: APIError?

        sut.loadImage(url: "bad url")
            .sink(
                receiveCompletion: {
                    if case let .failure(error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        dataTaskProviderSpy.stubbedTaskSubject.send((data: Data(), response: HTTPURLResponse.success))
        XCTAssertEqual(caughtError, .somethingWentWrong)
    }

    func test_tracks() throws {
        var caughtTracksResult: TracksResult?

        sut.perform(.tracks(albumId: 158, index: 4))
            .sink(receiveCompletion: { _ in },
                  receiveValue: { caughtTracksResult = $0 }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)
        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith.first?.absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/album/158/tracks?index=4")

        let bundle = Bundle(for: type(of:self))
        let resultPath = bundle.path(forResource: "tracks_result", ofType: "json")!
        let contentsData = try String(contentsOfFile: resultPath).data(using: .utf8)!

        dataTaskProviderSpy.stubbedTaskSubject.send((data: contentsData, response: HTTPURLResponse.success))
        XCTAssertEqual(caughtTracksResult?.data.count, 3)

        let expectedTracks: [Track] = .realTracks

        let actualAlbums = caughtTracksResult?.data
        XCTAssertEqual(actualAlbums, expectedTracks)
    }

}

private extension Array where Element == Album {

    static var realAlbums: [Album] {
        [
            Album(
                id: 194219042,
                title: "Music To Be Murdered By - Side B (Deluxe Edition)",
                coverMedium: "http://e-cdn-images.deezer.com/images/cover/55d424a53904d145b17869ba133843d7/250x250-000000-80-0-0.jpg",
                coverXl: "http://e-cdn-images.deezer.com/images/cover/55d424a53904d145b17869ba133843d7/1000x1000-000000-80-0-0.jpg"
            ),
            Album(
                id: 127270232,
                title: "Music To Be Murdered By",
                coverMedium: "http://e-cdn-images.deezer.com/images/cover/4d00a7848dc8af475973ff1761ad828d/250x250-000000-80-0-0.jpg",
                coverXl: "http://e-cdn-images.deezer.com/images/cover/4d00a7848dc8af475973ff1761ad828d/1000x1000-000000-80-0-0.jpg"
            ),
            Album(
                id: 72000342,
                title: "Kamikaze",
                coverMedium: "http://e-cdn-images.deezer.com/images/cover/bf74fc764097630ba58782ae79cfbee6/250x250-000000-80-0-0.jpg",
                coverXl: "http://e-cdn-images.deezer.com/images/cover/bf74fc764097630ba58782ae79cfbee6/1000x1000-000000-80-0-0.jpg"
            )
        ]
    }

}

private extension Array where Element == Track {

    static var realTracks: [Track] {
        [
            Track(title: "Oops!...I Did It Again", duration: 211, trackPosition: 1, diskNumber: 1),
            Track(title: "Stronger", duration: 203, trackPosition: 2, diskNumber: 1),
            Track(title: "Don't Go Knockin' on My Door", duration: 223, trackPosition: 3, diskNumber: 1)
        ]
    }

}
