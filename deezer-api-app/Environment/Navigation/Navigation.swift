import UIKit

class Navigation: NavigationProtocol {

    init(navigationController: UINavigationController,
         controllerFactory: ControllerFactoring) {
        self.navigationController = navigationController
        self.controllerFactory = controllerFactory
    }

    // MARK: - NavigationProtocol

    func go(to route: Route) {
        let controller = controllerFactory.createController(for: route)
        navigationController.pushViewController(controller, animated: true)
    }

    // MARK: - Private

    private let navigationController: UINavigationController
    private let controllerFactory: ControllerFactoring

}
