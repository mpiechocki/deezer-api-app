import UIKit

protocol NavigationProtocol {
    var navigationController: UINavigationController { get }

    func go(to: Route)
}
