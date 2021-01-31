import XCTest
@testable import deezer_api_app

class AlbumsViewControllerTests: XCTestCase {

    var savedNavigation: NavigationProtocol!
    var navigationSpy: NavigationSpy!
    var deezerServiceSpy: DeezerServiceSpy!
    var sut: AlbumsViewController!

    override func setUp() {
        super.setUp()
        navigationSpy = NavigationSpy()
        savedNavigation = Environment.navigation
        Environment.navigation = navigationSpy


        deezerServiceSpy = DeezerServiceSpy()
        sut = AlbumsViewController(artistId: 123456, deezerService: deezerServiceSpy)
    }

    override func tearDown() {
        sut = nil
        deezerServiceSpy = nil
        navigationSpy = nil

        Environment.navigation = savedNavigation
        savedNavigation = nil
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

        sut.albums = .stubbedAlbums

        XCTAssertEqual(sut.collectionView(collectionView, numberOfItemsInSection: 0), 3)

        let cell1 = sut.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as? AlbumCell
        XCTAssertNotNil(cell1)
        XCTAssertEqual(cell1?.titleLabel.text, "Garage Inc.")

        let cell3 = sut.collectionView(collectionView, cellForItemAt: IndexPath(row: 2, section: 0)) as? AlbumCell
        XCTAssertNotNil(cell3)
        XCTAssertEqual(cell3?.titleLabel.text, "Master Of Puppets")
    }

    func test_loadingCellImages() {
        sut.loadViewIfNeeded()
        sut.view.frame = .init(origin: .zero, size: .init(width: 200, height: 500))
        sut.view.layoutIfNeeded()

        let collectionView = sut.albumsView.collectionView
        sut.albums = .stubbedAlbums
        let cell = sut.collectionView(collectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as? AlbumCell
        XCTAssertEqual(deezerServiceSpy.imageCalledWith.count, 1)
        XCTAssertEqual(deezerServiceSpy.imageCalledWith.first, "https://url.to/128.jpg")
        XCTAssertNil(cell?.imageView.image)

        let stubbedImage = UIImage()
        deezerServiceSpy.stubbedImageSubject.send(stubbedImage)
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)
        XCTAssertTrue(cell?.imageView.image === stubbedImage)
    }

    func test_loadingAlbums() {
        sut.loadViewIfNeeded()

        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.count, 1)
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.first?.artistId, 123456)
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.first?.index, 0)

        deezerServiceSpy.stubbedAlbumsSubject.send(AlbumsResult(data: .stubbedAlbums, total: 3))
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)
        XCTAssertEqual(sut.albums, .stubbedAlbums)
    }

    func test_pagination() {
        sut.loadViewIfNeeded()
        let stubbedAlbumsResult1 = AlbumsResult(
            data: [.init(id: 128, title: "+", coverMedium: "", coverXl: ""), .init(id: 129, title: "*", coverMedium: "", coverXl: "")],
            total: 5
        )
        deezerServiceSpy.stubbedAlbumsSubject.send(stubbedAlbumsResult1)
        let mainThread = XCTestExpectation(description: "main thread")
        _ = XCTWaiter.wait(for: [mainThread], timeout: 0.1)

        XCTAssertEqual(sut.albums, stubbedAlbumsResult1.data)

        let collectionView = sut.albumsView.collectionView

        collectionView.delegate?.collectionView?(collectionView, willDisplay: UICollectionViewCell(), forItemAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.count, 1)

        collectionView.delegate?.collectionView?(collectionView, willDisplay: UICollectionViewCell(), forItemAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.count, 2)
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.last?.artistId, 123456)
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.last?.index, 2)

        let stubbedAlbumsResult2 = AlbumsResult(
            data: [
                .init(id: 130, title: "/", coverMedium: "", coverXl: ""),
                .init(id: 131, title: "Greatest hits", coverMedium: "", coverXl: ""),
                .init(id: 132, title: "+ (Deluxe)", coverMedium: "", coverXl: "")
            ],
            total: 5
        )

        deezerServiceSpy.stubbedAlbumsSubject.send(stubbedAlbumsResult2)
        let mainThread2 = XCTestExpectation(description: "main thread 2")
        _ = XCTWaiter.wait(for: [mainThread2], timeout: 0.1)
        print(sut.albums)
        XCTAssertEqual(sut.albums.count, 5)
        XCTAssertEqual(sut.albums, stubbedAlbumsResult1.data + stubbedAlbumsResult2.data)

        collectionView.delegate?.collectionView?(collectionView, willDisplay: UICollectionViewCell(), forItemAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.count, 2)

        collectionView.delegate?.collectionView?(collectionView, willDisplay: UICollectionViewCell(), forItemAt: IndexPath(row: 4, section: 0))
        XCTAssertEqual(deezerServiceSpy.albumsCalledWith.count, 2)
    }

    func test_cellSelect() {
        sut.loadViewIfNeeded()
        sut.albums = .stubbedAlbums

        let collectionView = sut.albumsView.collectionView

        sut.collectionView(collectionView, didSelectItemAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(navigationSpy.goCalledWith.count, 1)
        let expectedAlbumDetails = AlbumDetails(albumId: 1024, coverPath: "https://url.to/2048.jpg")
        XCTAssertEqual(navigationSpy.goCalledWith.first, .albumDetails(albumDetails: expectedAlbumDetails))
    }

}
