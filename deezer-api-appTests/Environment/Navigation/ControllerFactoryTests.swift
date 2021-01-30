import XCTest
@testable import deezer_api_app

class ControllerFactoryTests: XCTestCase {

    var sut: ControllerFactory!

    override func setUp() {
        super.setUp()

        sut = ControllerFactory()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_createSearchController() {
        let createdController = sut.createController(for: .search)

        XCTAssertTrue(type(of: createdController) == SearchViewController.self)
    }

    func test_createAlbumsController() {
        let createdController = sut.createController(for: .albums(artistId: 4))

        XCTAssertTrue(type(of: createdController) == AlbumsViewController.self)
        XCTAssertEqual((createdController as? AlbumsViewController)?.artistId, 4)
    }

}
