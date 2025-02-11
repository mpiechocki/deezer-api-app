import Combine
import UIKit
import XCTest
@testable import deezer_api_app

class SearchViewControllerTests: XCTestCase {

    var savedNavigation: NavigationProtocol!
    var navigationSpy: NavigationSpy!
    var deezerServiceSpy: DeezerServiceSpy!
    var sut: SearchViewController!

    override func setUp() {
        super.setUp()
        navigationSpy = NavigationSpy()
        savedNavigation = Environment.navigation
        Environment.navigation = navigationSpy

        deezerServiceSpy = DeezerServiceSpy()
        sut = SearchViewController(deezerService: deezerServiceSpy)
    }

    override func tearDown() {
        sut = nil
        deezerServiceSpy = nil
        navigationSpy = nil

        Environment.navigation = savedNavigation
        super.tearDown()
    }

    func test_title() {
        XCTAssertEqual(sut.title, "Search")
    }

    func test_view() {
        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view as? SearchView)
    }

    func test_searchBar() {
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.searchView.searchBar.placeholder, "Artist's name")
        XCTAssertTrue(sut.searchView.searchBar.delegate === sut)
    }

    func test_dismissingKeyboard() {
        sut.loadViewIfNeeded()
        sut.searchView.searchBar.becomeFirstResponder()

        sut.searchBarSearchButtonClicked(sut.searchView.searchBar)
        XCTAssertTrue(!sut.searchView.searchBar.isFirstResponder)
    }

    func test_tableView() {
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.searchView.tableView.dataSource === sut)
        XCTAssertTrue(sut.searchView.tableView.delegate === sut)
        XCTAssertNotNil(sut.searchView.tableView.tableFooterView)

        let tableView = sut.searchView.tableView

        let initialNumberOfRows = sut.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(initialNumberOfRows, 0)

        sut.artists = [
            .init(id: 1, name: "Shakira"),
            .init(id: 2, name: "Albatross"),
            .init(id: 3, name: "Machine Head")
        ]

        let numberOfRows = sut.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, 3)

        let cell1 = sut.tableView(tableView, cellForRowAt: .init(row: 0, section: 0))

        XCTAssertTrue(type(of: cell1) == UITableViewCell.self)
        XCTAssertEqual(cell1.textLabel?.text, "Shakira")

        let cell2 = sut.tableView(tableView, cellForRowAt: .init(row: 1, section: 0))
        let cell3 = sut.tableView(tableView, cellForRowAt: .init(row: 2, section: 0))

        XCTAssertEqual(cell2.textLabel?.text, "Albatross")
        XCTAssertEqual(cell3.textLabel?.text, "Machine Head")

        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(navigationSpy.goCalledWith.count, 1)
        XCTAssertEqual(navigationSpy.goCalledWith.first, .albums(title: "Albatross", artistId: 2))
    }

    func test_searchSuccess() {
        sut.loadViewIfNeeded()

        sut.searchBar(sut.searchView.searchBar, textDidChange: "k")

        let throttling = XCTestExpectation(description: "throttling")
        _ = XCTWaiter.wait(for: [throttling], timeout: 0.1)
        XCTAssertEqual(deezerServiceSpy.searchCalledWith.count, 1)
        XCTAssertEqual(deezerServiceSpy.searchCalledWith.first, "k")
        XCTAssertEqual(sut.artists.count, 0)

        let stubbedArtists: [Artist] = [
            .init(id: 123, name: "Korn"),
            .init(id: 414, name: "Kygo"),
            .init(id: 42312, name: "Katie Melua")
        ]
        deezerServiceSpy.stubbedSearchSubject.send(stubbedArtists)

        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)

        XCTAssertEqual(sut.artists.count, 3)
        XCTAssertEqual(sut.artists, stubbedArtists)
    }

    func test_searchFailure() {
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 400)))
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.loadViewIfNeeded()

        sut.searchBar(sut.searchView.searchBar, textDidChange: "f")

        let throttling = XCTestExpectation(description: "throttling")
        _ = XCTWaiter.wait(for: [throttling], timeout: 0.1)

        deezerServiceSpy.stubbedSearchSubject.send(completion: .failure(.somethingWentWrong))

        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)

        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.title, "Error")
        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.actions.count, 1)
        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.actions.first?.title, "Ok")
    }

}
