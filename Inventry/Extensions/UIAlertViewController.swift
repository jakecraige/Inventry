import UIKit
import PromiseKit

struct CancelledAlertError: Error {}

extension UIAlertController {
  /// Presents a `UIAlertController` with an "OK" and "Cancel" button.
  /// Returns a `Promise` that resolves when "OK" is tapped and rejects with a
  /// `CancelledAlertError` when "Cancel" is tappped.
  static func okCancel(title: String, message: String, presentingVC: UIViewController) -> Promise<Void> {
    return Promise { resolve, reject in
      let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
      avc.addAction(UIAlertAction(
        title: "Cancel",
        style: .default,
        handler: { _ in reject(CancelledAlertError()) }
      ))
      avc.addAction(UIAlertAction(
        title: "OK",
        style: .default,
        handler: { _ in resolve() }
      ))
      presentingVC.present(avc, animated: true, completion: .none)
    }
  }

  /// Presents a `UIAlertController` with an "OK" button and resolves when it's tapped.
  /// The returned promise will _never_ reject
  static func ok(title: String, message: String, presentingVC: UIViewController) -> Promise<Void> {
    return Promise { resolve, reject in
      let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
      avc.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in resolve() }))
      presentingVC.present(avc, animated: true, completion: .none)
    }
  }
}
