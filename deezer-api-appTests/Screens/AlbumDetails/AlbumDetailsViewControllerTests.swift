import XCTest
import UIKit
@testable import deezer_api_app

class AlbumDetailsViewControllerTests: XCTestCase {

    var albumDetails: AlbumDetails!
    var deezerServiceSpy: DeezerServiceSpy!
    var sut: AlbumDetailsViewController!

    override func setUp() {
        super.setUp()
        albumDetails = .init(name: "Kamikaze", albumId: 142, coverPath: "http://images.com/cover.jpg")
        deezerServiceSpy = DeezerServiceSpy()
        sut = AlbumDetailsViewController(albumDetails: albumDetails, deezerService: deezerServiceSpy)
    }

    override func tearDown() {
        sut = nil
        albumDetails = nil
        deezerServiceSpy = nil
        super.tearDown()
    }

    func test_title() {
        XCTAssertEqual(sut.title, "Kamikaze")
    }

    func test_view() {
        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view as? AlbumDetailsView)
    }

    func test_tableViewConfiguration() {
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.albumDetailsView.tableView.dataSource === sut)
        XCTAssertTrue(sut.albumDetailsView.tableView.delegate === sut)
        XCTAssertNotNil(sut.albumDetailsView.tableView.tableHeaderView as? AlbumHeader)
        XCTAssertNotNil(sut.albumDetailsView.tableView.tableFooterView)
    }

    func test_tableViewHeaderView() {
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 500))
        sut.view.layoutIfNeeded()

        sut.viewDidLayoutSubviews()
        XCTAssertEqual(sut.albumDetailsView.tableView.tableHeaderView?.frame, CGRect(origin: .zero, size: CGSize(width: 0, height: 100)))
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
        XCTAssertEqual(cell1?.diskNumberLabel.text, "disk 1.")
        XCTAssertEqual(cell1?.titleLabel.text, "Second Hand News")
        XCTAssertEqual(cell1?.durationLabel.text, "2:00")

        let cell3 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as? TrackCell
        XCTAssertEqual(cell3?.numberLabel.text, "3.")
        XCTAssertEqual(cell3?.diskNumberLabel.text, "disk 3.")
        XCTAssertEqual(cell3?.titleLabel.text, "Never Going Back Again")
        XCTAssertEqual(cell3?.durationLabel.text, "7:11")
    }

    func test_loadingCover() {
        sut.loadViewIfNeeded()
        XCTAssertEqual(deezerServiceSpy.imageCalledWith.count, 1)
        XCTAssertEqual(deezerServiceSpy.imageCalledWith.first, "http://images.com/cover.jpg")
        let headerView = sut.albumDetailsView.tableView.tableHeaderView as? AlbumHeader
        XCTAssertEqual(headerView!.imageView.alpha, 0.3, accuracy: 0.01)

        let stubbedImage = UIImage()
        deezerServiceSpy.stubbedImageSubject.send(stubbedImage)
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)
        XCTAssertTrue(headerView?.imageView.image == stubbedImage)
        XCTAssertEqual(headerView?.imageView.alpha, 1.0)
    }

    func test_loadingTracksSuccess() {
        sut.loadViewIfNeeded()
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.count, 1)
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.first?.albumId, 142)
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.first?.index, 0)

        XCTAssertEqual(sut.tracks.count, 0)
        let tracksResult = TracksResult(data: .stubbedTracks, total: 3)
        deezerServiceSpy.stubbedTracksSubject.send(tracksResult)
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)
        XCTAssertEqual(sut.tracks, tracksResult.data)

        deezerServiceSpy.stubbedTracksSubject.send(tracksResult)
        let mainThread2 = XCTestExpectation(description: "main thread 2")
        _ = XCTWaiter.wait(for: [mainThread2], timeout: 0.1)
        XCTAssertEqual(sut.tracks.count, 3)
    }

    func test_loadingTracksFailure() {
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 400)))
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.loadViewIfNeeded()

        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.count, 1)

        deezerServiceSpy.stubbedTracksSubject.send(completion: .failure(.somethingWentWrong))
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)

        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.title, "Error")
        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.actions.count, 1)
        XCTAssertEqual((sut.presentedViewController as? UIAlertController)?.actions.first?.title, "Ok")
    }

    func test_loadingMoreTracks() {
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 500))
        sut.view.layoutIfNeeded()

        let firstPageTracks: [Track] = [
            .init(title: "Title 1", duration: 90, trackPosition: 1, diskNumber: 1),
            .init(title: "Title 2", duration: 120, trackPosition: 2, diskNumber: 1),
            .init(title: "Title 3", duration: 180, trackPosition: 3, diskNumber: 1)
        ]
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.count, 1)
        deezerServiceSpy.stubbedTracksSubject.send(TracksResult(data: firstPageTracks, total: 5))
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)

        let tableView = sut.albumDetailsView.tableView
        sut.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.count, 1)

        sut.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.count, 2)

        let additionalTracks: [Track] = [
            .init(title: "Title 5", duration: 12, trackPosition: 5, diskNumber: 1),
            .init(title: "Title 4", duration: 73, trackPosition: 1, diskNumber: 2)
        ]
        deezerServiceSpy.stubbedTracksSubject.send(TracksResult(data: additionalTracks, total: 5))
        let mainThread2 = XCTestExpectation(description: "main thread 2")
        _ = XCTWaiter.wait(for: [mainThread2], timeout: 0.1)

        let expectedSortedTracks: [Track] = [
            .init(title: "Title 1", duration: 90, trackPosition: 1, diskNumber: 1),
            .init(title: "Title 2", duration: 120, trackPosition: 2, diskNumber: 1),
            .init(title: "Title 3", duration: 180, trackPosition: 3, diskNumber: 1),
            .init(title: "Title 5", duration: 12, trackPosition: 5, diskNumber: 1),
            .init(title: "Title 4", duration: 73, trackPosition: 1, diskNumber: 2)
        ]
        XCTAssertEqual(sut.tracks, expectedSortedTracks)

        sut.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 4, section: 0))
        XCTAssertEqual(deezerServiceSpy.tracksCalledWith.count, 2)
    }

}
