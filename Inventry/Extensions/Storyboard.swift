import UIKit

enum Storyboard: String {
  case Main
  case OrderFlow
  case Onboarding
}

extension UIStoryboard {
  static func instantiateInitialViewController(forStoryboard storyboard: Storyboard) -> UIViewController {
    return UIStoryboard(name: storyboard.rawValue, bundle: .none).instantiateInitialViewController()!
  }

  static func instantiateViewController(withIdentifier identifier: String, fromStoryboard storyboard: Storyboard) -> UIViewController? {
    return UIStoryboard(name: storyboard.rawValue, bundle: .none).instantiateViewController(withIdentifier: identifier)
  }
}
