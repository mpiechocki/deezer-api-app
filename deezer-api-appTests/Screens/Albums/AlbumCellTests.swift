import XCTest
import UIKit
@testable import deezer_api_app

class AlbumCellTests: XCTestCase {

    var sut: AlbumCell!

    override func setUp() {
        super.setUp()
        sut = AlbumCell()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_prepareForReuse() {
        sut.imageView.image = UIImage()
        sut.imageView.alpha = 1.0
        sut.titleLabel.text = "Death Magnetic"

        sut.prepareForReuse()

        XCTAssertTrue(sut.imageView.image === UIImage(systemName: "arrow.up.arrow.down")!.withRenderingMode(.alwaysOriginal))
        XCTAssertNil(sut.titleLabel.text)
        XCTAssertEqual(sut.imageView.alpha, 0.3, accuracy: 0.01)
    }

}
