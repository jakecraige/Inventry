import UIKit
import Firebase
import HockeySDK
import MessageUI

private enum Cell: Int {
    case inventorySharing
    case feedback
}

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

extension SettingsViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let cellType = Cell(rawValue: indexPath.row) else { return }

    switch cellType {
    case .feedback: presentFeedbackForm()
    case .inventorySharing: break
    }
  }
}

private extension SettingsViewController {
  func initializeMailController() -> MFMailComposeViewController? {
    guard MFMailComposeViewController.canSendMail() else { return .none }

    let vc = MFMailComposeViewController()
    vc.mailComposeDelegate = self
    vc.setToRecipients([Environment.feedbackEmail])
    vc.setSubject("Inventory Feedback")
    vc.setMessageBody("", isHTML: false)

    return vc
  }

  func presentFeedbackForm() {
    if let vc = initializeMailController() {
      present(vc, animated: true, completion: .none)
    } else {
      _ = UIAlertController.ok(
        title: "Feedback",
        message: "Please send an email with your feeback to \"\(Environment.feedbackEmail)\" and we'll get back to you shortly.",
        presentingVC: self
      )
    }
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true) {
      _ = UIAlertController.ok(
        title: "Thanks!",
        message: "We really appreciate your feedback. We'll review it and get back to you shortly.",
        presentingVC: self
      )
    }
  }
}
