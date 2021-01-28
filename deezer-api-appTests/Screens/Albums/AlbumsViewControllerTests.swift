import XCTest
@testable import deezer_api_app

class AlbumsViewControllerTests: XCTestCase {

    var sut: AlbumsViewController!

    override func setUp() {
        super.setUp()
        sut = AlbumsViewController()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_collectionView() {
        sut.loadViewIfNeeded()
        sut.view.frame = .init(origin: .zero, size: .init(width: 200, height: 500))
        sut.view.layoutIfNeeded()

        XCTAssertTrue(sut.albumsView.collectionView.dataSource === sut)
        XCTAssertTrue(sut.albumsView.collectionView.delegate === sut)

        let collectionView = sut.albumsView.collectionView

        let horizontalSpacing = sut.collectionView(collectionView, layout: collectionView.collectionViewLayout, minimumInteritemSpacingForSectionAt: 0)
        XCTAssertEqual(horizontalSpacing, 4)
        let verticalSpacing = sut.collectionView(collectionView, layout: collectionView.collectionViewLayout, minimumLineSpacingForSectionAt: 0)
        XCTAssertEqual(verticalSpacing, 4)
        let itemSize = sut.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: .init(row: 3, section: 0))
        XCTAssertEqual(itemSize, CGSize(width: 92, height: 101.2))

        XCTAssertEqual(sut.collectionView(collectionView, numberOfItemsInSection: 0), 0)
        let stubbedAlbums: [Album] = [
            .init(id: 128, title: "Garage Inc."),
            .init(id: 256, title: "S&M"),
            .init(id: 1024, title: "Master Of Puppets")
        ]

        sut.albums = stubbedAlbums

        XCTAssertEqual(sut.collectionView(collectionView, numberOfItemsInSection: 0), 3)

        let cell1 = sut.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as? AlbumCell
        XCTAssertNotNil(cell1)
        XCTAssertEqual(cell1?.titleLabel.text, "Garage Inc.")

        let cell3 = sut.collectionView(collectionView, cellForItemAt: IndexPath(row: 2, section: 0)) as? AlbumCell
        XCTAssertNotNil(cell3)
        XCTAssertEqual(cell3?.titleLabel.text, "Master Of Puppets")
    }

}
