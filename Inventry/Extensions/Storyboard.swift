import UIKit

enum Storyboard: String {
  case Main
}

extension UIStoryboard {
  static func instantiateViewController(withIdentifier identifier: String, fromStoryboard storyboard: Storyboard) -> UIViewController? {
    return UIStoryboard(name: storyboard.rawValue, bundle: .None).instantiateViewControllerWithIdentifier(identifier)
  }
}
