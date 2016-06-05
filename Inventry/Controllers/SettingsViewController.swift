import UIKit
import Firebase
import HockeySDK

private enum Cell: Int {
  case feedback
}

class SettingsViewController: UITableViewController {
  @IBAction func signOutTapped(sender: UIBarButtonItem) {
    do {
      try FIRAuth.auth()?.signOut()
    } catch {
      print(error)
      UIAlertController.ok(
        title: "Uh oh!",
        message: "Something weird is going on that's causing us to not be able to sign you out. Please try again later.",
        presentingVC: self
      )
    }
  }
}

// MARK: UITableViewDelegate
extension SettingsViewController {
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let cellType = Cell(rawValue: indexPath.row) else { return }

    switch cellType {
    case .feedback:
      let manager = BITHockeyManager.sharedHockeyManager().feedbackManager
      let vc = manager.feedbackListViewController(false)
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}
