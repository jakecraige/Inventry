import UIKit
import Stripe

private enum Cell: Int {
  case name
  case phone
  case email
  case creditCard
}
private let numberOfCells = 4

class OrderPaymentViewController: UITableViewController {
  @IBOutlet var reviewButton: UIBarButtonItem!

  var order: Order!
  var name: String? = "" { didSet { updateReviewButtonEnabled() } }
  var phone: String? = ""
  var email: String? = ""
  var paymentValid = false
  var paymentParams: STPCardParams?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )
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
    order.customer = Customer(
      name: name!, // Review is disabled until this is set
      email: email,
      phone: phone
    )
    if paymentValid {
      validatePayment()
    } else {
      performSegueWithIdentifier("reviewSegue", sender: self)
    }
  }

  private func validatePayment() {
    guard let params = paymentParams else { return }
    startLoading()
    PaymentProvier.createToken(params).then { token -> Void in
      self.order.paymentToken = token
      self.performSegueWithIdentifier("reviewSegue", sender: self)
    }.always {
      self.stopLoading()
    }.error { error in
      print(error)
    }
  }

  private func updateReviewButtonEnabled() {
    let nameFieldPresent = !(name ?? "").isEmpty
    reviewButton.enabled = nameFieldPresent && paymentValid
  }

  private func startLoading() {
    navigationItem.startLoadingRightButton()
  }

  private func stopLoading() {
    navigationItem.stopLoadingRightButton()
    navigationItem.rightBarButtonItem?.enabled = paymentValid
  }

  @IBAction func nameFieldEditingChanged() {
    updateReviewButtonEnabled()
  }
}

// MARK: UITableViewDataSource
extension OrderPaymentViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfCells
  }
}

// MARK: UITableViewDelegate
extension OrderPaymentViewController {
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cellType = Cell(rawValue: indexPath.row) else { fatalError("Unknown cell type") }

    if cellType == .creditCard {
      let cell = tableView.dequeueReusableCellWithIdentifier("creditCardCell", forIndexPath: indexPath) as! CreditCardTableViewCell
      cell.paymentTextField.delegate = self
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("formTextFieldCell", forIndexPath: indexPath) as! FormTextFieldTableViewCell
      switch cellType {
      case .name:
        cell.keyboardType = .Default
        cell.configure("Name", value: name) { [weak self] in self?.name = $0 }
      case .phone:
        cell.keyboardType = .NumberPad
        cell.configure("Phone", value: phone) { [weak self] in self?.phone = $0 }
      case .email:
        cell.keyboardType = .EmailAddress
        cell.configure("Email", value: email) { [weak self] in self?.email = $0 }
      default: fatalError("New cell type that hasn't been handled yet")
      }
      return cell
    }
  }
}

// MARK: STPPaymentCardTextFieldDelegate
extension OrderPaymentViewController: STPPaymentCardTextFieldDelegate {
  func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
    paymentValid = textField.valid
    paymentParams = textField.cardParams
    updateReviewButtonEnabled()
  }
}
