import UIKit
import Stripe

class OrderPaymentViewController: UITableViewController {
  @IBOutlet var reviewButton: UIBarButtonItem!
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
    paymentTextField.delegate = self
    creditCardView.addSubview(paymentTextField)
    nameField.becomeFirstResponder()
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

  @IBAction func reviewTapped(sender: UIBarButtonItem) {
    if paymentTextField.valid {
      validatePayment()
    } else {
      performSegueWithIdentifier("reviewSegue", sender: self)
    }
  }

  private func validatePayment() {
    startLoading()
    PaymentProvier.createToken(paymentTextField.cardParams).then { token -> Void in
      self.order.paymentToken = token
      self.performSegueWithIdentifier("reviewSegue", sender: self)
    }.always {
      self.stopLoading()
    }.error { error in
      print(error)
    }
  }

  private func startLoading() {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let button = UIBarButtonItem(customView: indicator)
    self.navigationItem.rightBarButtonItem = button
    indicator.startAnimating()
  }

  private func stopLoading() {
    let button = UIBarButtonItem()
    button.title = "Review"
    button.enabled = paymentTextField.valid
    self.navigationItem.rightBarButtonItem = button
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
  func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
    reviewButton.enabled = textField.valid
  }
}
