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

    func test_perform_url_success() throws {
        var caughtString: String?

        sut.perform()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { caughtString = $0 }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith[0].absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/search/artist?q=kygo")

        let response = HTTPURLResponse.success
        dataTaskProviderSpy.stubbedTaskSubject.send((data: Data(), response: response))
        XCTAssertEqual(caughtString, "response")
    }

    func test_perform_url_failure() {
        var caughtError: Error?

        sut.perform()
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith[0].absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/search/artist?q=kygo")

        let response = HTTPURLResponse.forbidden
        dataTaskProviderSpy.stubbedTaskSubject.send((data: Data(), response: response))
        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
    }

    func test_perform_session_failure() {
        var caughtError: Error?

        sut.perform()
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        caughtError = error
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        XCTAssertEqual(dataTaskProviderSpy.dataTaskPublisherCalledWith.count, 1)

        let urlString = dataTaskProviderSpy.dataTaskPublisherCalledWith[0].absoluteString
        XCTAssertEqual(urlString, "https://api.deezer.com/search/artist?q=kygo")

        dataTaskProviderSpy.stubbedTaskSubject.send(completion: .failure(URLError(.cannotFindHost)))
        XCTAssertEqual(caughtError as? APIError, APIError.somethingWentWrong)
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
