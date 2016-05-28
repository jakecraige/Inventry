import UIKit
import Stripe

class OrderPaymentViewController: UITableViewController {
  @IBOutlet var nameField: UITextField!
  @IBOutlet var phoneField: UITextField!
  @IBOutlet var emailField: UITextField!
  @IBOutlet var creditCardView: UIView!
  let paymentTextField = STPPaymentCardTextField()

  var order: Order!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    nameField.text = ""
    phoneField.text = ""
    emailField.text = ""
    paymentTextField.translatesAutoresizingMaskIntoConstraints = false
    paymentTextField.borderWidth = 0
    creditCardView.addSubview(paymentTextField)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "reviewSegue":
      let vc = segue.destinationViewController as? OrderReviewViewController
      vc?.order = order
    default: break
    }
  }
}

// MARK: UITableViewDelegate
extension OrderPaymentViewController {
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
}

// MARK: STPPaymentCardTextFieldDelegate
extension OrderPaymentViewController: STPPaymentCardTextFieldDelegate {
}
