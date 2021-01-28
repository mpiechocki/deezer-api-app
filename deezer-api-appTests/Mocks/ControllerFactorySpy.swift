import UIKit
@testable import deezer_api_app

class ControllerFactorySpy: ControllerFactoring {

    var stubbedController = UIViewController()
    var createControllerCalledWith = [Route]()

    func createController(for route: Route) -> UIViewController {
        createControllerCalledWith.append(route)

        return stubbedController
    }

}
