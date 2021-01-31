import XCTest
import UIKit
@testable import deezer_api_app

class TrackCellTests: XCTestCase {

    var sut: TrackCell!

    override func setUp() {
        super.setUp()
        sut = TrackCell()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_prepareForReuse() {
        sut.numberLabel.text = "2."
        sut.diskNumberLabel.text = "disk 3."
        sut.titleLabel.text = "Death Magnetic"
        sut.durationLabel.text = "7:34"

        sut.prepareForReuse()

        XCTAssertNil(sut.numberLabel.text)
        XCTAssertNil(sut.diskNumberLabel.text)
        XCTAssertNil(sut.titleLabel.text)
        XCTAssertNil(sut.durationLabel.text)
    }

}
