import UIKit
@testable import deezer_api_app

class NavigationSpy: NavigationProtocol {

    var goCalledWith = [Route]()

    // MARK: - NavigationProtocol

    let navigationController = UINavigationController()

    func go(to route: Route) {
        goCalledWith.append(route)
    }

}
