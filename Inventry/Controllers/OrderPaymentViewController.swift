import UIKit
import Stripe
import PromiseKit

private enum Cell: Int {
  case name
  case phone
  case email
  case creditCard
}
private let numberOfCells = 4

class OrderPaymentViewController: UITableViewController {
  @IBOutlet var buyButton: UIBarButtonItem!

  var viewModel = OrderViewModel.null()
  var name: String? { didSet { updateReviewButtonEnabled() } }
  var phone: String?
  var email: String?
  var paymentValid = false
  var paymentParams = STPCardParams()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNib(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )
  }

  @IBAction func buyTapped(sender: UIBarButtonItem) {
    navigationItem.startLoadingRightButton()

    viewModel.order.customer = Customer(
      name: name!, // Buy is disabled until this is set
      email: email,
      phone: phone
    )

    validatePaymentMethod()
      .then(confirmOkayToChargeCard)
      .then(placeOrder)
      .then { [weak self] in self?.dismissViewControllerAnimated(true, completion: nil) }
      .always { [weak self] in self?.navigationItem.stopLoadingRightButton() }
      .error { error in
      if error is CancelledAlertError {
        // ignore
      } else {
        print(error)
        self.handleProcessError(error)
      }
    }
  }

  private func validatePaymentMethod() -> Promise<Void> {
    return PaymentProvier.createToken(paymentParams).then { token in
      self.viewModel.order.paymentToken = token
    }
  }

  private func confirmOkayToChargeCard() -> Promise<Void> {
    let amount = PriceFormatter(viewModel.total).formatted
    return UIAlertController.okCancel(
      title: "Confirm Purchase",
      message: "This will charge the credit card \(amount), is that okay?",
      presentingVC: self
    )
  }

  private func placeOrder() -> Promise<Void> {
    let processor = OrderProcessor(vm: viewModel)

    return processor.process().then { order -> Void in
      print("Order completed: \(order)")
    }
  }

  private func handleProcessError(error: ErrorType) {
    UIAlertController.ok(
      title: "Uh oh!",
      message: "We're having trouble placing the order right now. Please try again later.",
      presentingVC: self
    )
  }

  private func updateReviewButtonEnabled() {
    let nameFieldPresent = !(name ?? "").isEmpty
    buyButton.enabled = nameFieldPresent && paymentValid
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
