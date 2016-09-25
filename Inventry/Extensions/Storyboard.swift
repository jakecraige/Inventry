import UIKit

enum Storyboard: String {
  case Main
  case OrderFlow
  case Onboarding
}

extension UIStoryboard {
  static func initialViewController<VCType: UIViewController>(storyboard: Storyboard) -> VCType {
    return UIStoryboard(
      name: storyboard.rawValue,
      bundle: .none
    ).instantiateInitialViewController() as! VCType
  }

  static func instantiateViewController(withIdentifier identifier: String, fromStoryboard storyboard: Storyboard) -> UIViewController {
    return UIStoryboard(
      name: storyboard.rawValue,
      bundle: .none
    ).instantiateViewController(withIdentifier: identifier)
  }
}
