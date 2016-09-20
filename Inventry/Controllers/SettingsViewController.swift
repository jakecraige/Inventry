import UIKit
import Firebase
import HockeySDK

class SettingsViewController: UITableViewController {
  @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
    do {
      try FIRAuth.auth()?.signOut()
    } catch {
      print(error)
      _ = UIAlertController.ok(
        title: "Uh oh!",
        message: "Something weird is going on that's causing us to not be able to sign you out. Please try again later.",
        presentingVC: self
      )
    }
  }
}
