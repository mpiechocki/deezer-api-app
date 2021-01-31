import UIKit

extension UIViewController {

    static var errorAlert: UIAlertController {
        let alert = UIAlertController(title: "Error", message: "Something went wrong. Sorry :(", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }

}
