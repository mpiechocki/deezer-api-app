import XCTest
import UIKit
@testable import deezer_api_app

class AlbumDetailsViewControllerTests: XCTestCase {

    var sut: AlbumDetailsViewController!

    override func setUp() {
        super.setUp()
        sut = AlbumDetailsViewController()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_view() {
        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view as? AlbumDetailsView)
    }

    func test_tableViewConfiguration() {
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.albumDetailsView.tableView.dataSource === sut)
        XCTAssertNotNil(sut.albumDetailsView.tableView.tableHeaderView as? AlbumHeader)
    }

    func test_tableViewHeaderView() {
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 500))
        sut.view.layoutIfNeeded()

        sut.viewDidLayoutSubviews()
        XCTAssertEqual(sut.albumDetailsView.tableView.tableHeaderView?.frame, CGRect(origin: .zero, size: CGSize(width: 0, height: 96)))
    }

    func test_tableView() {
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 500))
        sut.view.layoutIfNeeded()

        sut.tracks = .stubbedTracks

        let tableView = sut.albumDetailsView.tableView

        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 3)

        let cell1 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? TrackCell
        XCTAssertEqual(cell1?.numberLabel.text, "1.")
        XCTAssertEqual(cell1?.titleLabel.text, "Second Hand News")
        XCTAssertEqual(cell1?.durationLabel.text, "90")

        let cell3 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as? TrackCell
        XCTAssertEqual(cell3?.numberLabel.text, "3.")
        XCTAssertEqual(cell3?.titleLabel.text, "Never Going Back Again")
        XCTAssertEqual(cell3?.durationLabel.text, "431")
    }

}
