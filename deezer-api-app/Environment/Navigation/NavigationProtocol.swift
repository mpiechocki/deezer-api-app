import UIKit

protocol NavigationProtocol {
    var navigationController: UINavigationController { get set }

    func go(to: Route)
}
