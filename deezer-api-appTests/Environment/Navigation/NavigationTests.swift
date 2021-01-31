import UIKit
import XCTest
@testable import deezer_api_app

class NavigationTests: XCTestCase {

    var navigationController: NavigationControllerSpy!
    var controllerFactorySpy: ControllerFactorySpy!
    var sut: Navigation!

    override func setUp() {
        super.setUp()
        navigationController = NavigationControllerSpy()
        controllerFactorySpy = ControllerFactorySpy()
        sut = Navigation(navigationController: navigationController, controllerFactory: controllerFactorySpy)
    }

    override func tearDown() {
        sut = nil
        navigationController = nil
        controllerFactorySpy = nil
        super.tearDown()
    }

    func test_go() {
        let firstController = UIViewController(nibName: nil, bundle: nil)
        navigationController.stubbedViewControllers = [firstController]

        sut.go(to: .albums(title: "title", artistId: 1))

        XCTAssertEqual(controllerFactorySpy.createControllerCalledWith.count, 1)
        XCTAssertEqual(controllerFactorySpy.createControllerCalledWith.first, .albums(title: "title", artistId: 1))
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertTrue(navigationController.viewControllers.first === firstController)
        XCTAssertTrue(navigationController.viewControllers.last === controllerFactorySpy.stubbedController)
    }

}
