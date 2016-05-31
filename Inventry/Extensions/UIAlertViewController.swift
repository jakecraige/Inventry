import UIKit
import PromiseKit

struct CancelledAlertError: ErrorType {}

extension UIAlertController {
  /// Presents a `UIAlertController` with an "OK" and "Cancel" button.
  /// Returns a `Promise` that resolves when "OK" is tapped and rejects with a
  /// `CancelledAlertError` when "Cancel" is tappped.
  static func okCancel(title title: String, message: String, presentingVC: UIViewController) -> Promise<Void> {
    return Promise { resolve, reject in
      let avc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
      avc.addAction(UIAlertAction(
        title: "Cancel",
        style: .Default,
        handler: { _ in reject(CancelledAlertError()) }
      ))
      avc.addAction(UIAlertAction(
        title: "OK",
        style: .Default,
        handler: { _ in resolve() }
      ))
      presentingVC.presentViewController(avc, animated: true, completion: .None)
    }
  }

  /// Presents a `UIAlertController` with an "OK" button and resolves when it's tapped.
  /// The returned promise will _never_ reject
  static func ok(title title: String, message: String, presentingVC: UIViewController) -> Promise<Void> {
    return Promise { resolve, reject in
      let avc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
      avc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in resolve() }))
      presentingVC.presentViewController(avc, animated: true, completion: .None)
    }
  }
}
