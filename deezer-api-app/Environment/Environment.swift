import UIKit

class Environment {

    static var navigation: NavigationProtocol = Navigation(
        navigationController: UINavigationController(),
        controllerFactory: ControllerFactory()
    )

}
