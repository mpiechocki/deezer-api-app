import UIKit

class NavigationControllerSpy: UINavigationController {

    var stubbedViewControllers = [UIViewController]()

    override var viewControllers: [UIViewController] {
        get { stubbedViewControllers }
        set { stubbedViewControllers = newValue }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewControllers = viewControllers + [viewController]
    }

}
