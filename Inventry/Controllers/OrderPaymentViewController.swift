import UIKit
import Stripe
import PromiseKit
import RxSwift
import RxCocoa
import Firebase

private enum Cell: Int {
  case name
  case phone
  case email
  case creditCard
}
private let numberOfCells = 4

class OrderPaymentViewController: UITableViewController {
  @IBOutlet var buyButton: UIBarButtonItem!

  let disposeBag = DisposeBag()
  var viewModel = OrderViewModel.null()
  var customer: Customer { return viewModel.order.customer ?? Customer.null() }
  var paymentValid = Variable(false)
  var paymentParams = STPCardParams()

  var customerName: Driver<String> {
    return store.orderViewModel
      .map { $0.customer?.name ?? "" }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: "")
  }

  var formValid: Driver<Bool> {
    return Driver.combineLatest(customerName, paymentValid.asDriver()) { name, validPayment in
      return !name.isEmpty && validPayment
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )

    store.orderViewModel.subscribe(onNext: { [weak self] in
      self?.viewModel = $0
    }).addDisposableTo(disposeBag)

    formValid.drive(buyButton.rx.enabled).addDisposableTo(disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    CardIOUtilities.preload()
  }

  @IBAction func scanCreditCardTapped(_ sender: UIBarButtonItem) {
    let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
    cardIOVC?.modalPresentationStyle = .formSheet
    cardIOVC?.useCardIOLogo = true
    cardIOVC?.hideCardIOLogo = true
    present(cardIOVC!, animated: true, completion: nil)
  }

  @IBAction func buyTapped(_ sender: UIBarButtonItem) {
    navigationItem.startLoadingRightButton()

    validatePaymentMethod()
      .then(execute: confirmOkayToChargeCard)
      .then(execute: placeOrder)
      .then(execute: logOrderPurchase)
      .then { [weak self] in self?.dismiss(animated: true, completion: nil) }
      .always { [weak self] in self?.navigationItem.stopLoadingRightButton() }
      .catch { error in
        if error is CancelledAlertError {
          // ignore
        } else {
          print(error)
          self.handleProcessError(error)
        }
    }
  }

  fileprivate func validatePaymentMethod() -> Promise<Void> {
    return PaymentProvier.createToken(paymentParams).then { token in
      store.dispatch(UpdateCurrentOrder(paymentToken: token))
    }
  }

  fileprivate func confirmOkayToChargeCard() -> Promise<Void> {
    let amount = PriceFormatter(viewModel.total).formatted
    return UIAlertController.okCancel(
      title: "Confirm Purchase",
      message: "This will charge the credit card \(amount), is that okay?",
      presentingVC: self
    )
  }

  fileprivate func placeOrder() -> Promise<Void> {
    let processor = OrderProcessor(vm: viewModel)

    return processor.process().map { order -> Void in
      print("Order completed: \(order)")
    }.asPromise()
  }

  fileprivate func logOrderPurchase() {
    Analytics.logEvent(.CreateOrder, [
      kFIRParameterValue: (viewModel.subtotal / 100) as AnyObject,
      kFIRParameterCurrency: Currency.USD.rawValue as AnyObject,
      kFIRParameterShipping: (viewModel.shipping / 100) as AnyObject,
      kFIRParameterTax: (viewModel.tax / 100) as AnyObject,
      Analytics.Param.HasNotes.rawValue: !viewModel.order.notes.isEmpty as AnyObject
    ])
  }

  fileprivate func handleProcessError(_ error: Error) {
    _ = UIAlertController.ok(
      title: "Uh oh!",
      message: "We're having trouble placing the order right now. Please try again later.",
      presentingVC: self
    )
  }

  func setCardParams(_ number: String, expMonth: UInt, expYear: UInt, cvv: String) {
    paymentParams.number = number
    paymentParams.expMonth = expMonth
    paymentParams.expYear = expYear
    paymentParams.cvc = cvv
    tableView.reloadRows(
      at: [IndexPath(row: Cell.creditCard.rawValue, section: 0)],
      with: .automatic
    )
  }
}

// MARK: UITableViewDataSource
extension OrderPaymentViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfCells
  }
}

// MARK: UITableViewDelegate
extension OrderPaymentViewController {
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cellType = Cell(rawValue: (indexPath as NSIndexPath).row) else { fatalError("Unknown cell type") }

    if cellType == .creditCard {
      let cell = tableView.dequeueReusableCell(withIdentifier: "creditCardCell", for: indexPath) as! CreditCardTableViewCell
      cell.paymentTextField.delegate = self
      cell.paymentTextField.cardParams = paymentParams
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "formTextFieldCell", for: indexPath) as! FormTextFieldTableViewCell
      switch cellType {
      case .name:
        cell.keyboardType = .default
        cell.configure("Name", value: customer.name) { store.dispatch(UpdateCurrentOrderCustomer(name: $0)) }
      case .phone:
        cell.keyboardType = .numberPad
        cell.configure("Phone", value: customer.phone) { store.dispatch(UpdateCurrentOrderCustomer(phone: $0))}
      case .email:
        cell.keyboardType = .emailAddress
        cell.configure("Email", value: customer.email) { store.dispatch(UpdateCurrentOrderCustomer(email: $0))}
      default: fatalError("New cell type that hasn't been handled yet")
      }
      return cell
    }
  }
}

// MARK: STPPaymentCardTextFieldDelegate
extension OrderPaymentViewController: STPPaymentCardTextFieldDelegate {
  func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    paymentValid.value = textField.valid
    paymentParams = textField.cardParams
  }
}

extension OrderPaymentViewController: CardIOPaymentViewControllerDelegate {
  func userDidCancel(_ paymentViewController: CardIOPaymentViewController?) {
    paymentViewController?.dismiss(animated: true, completion: .none)
  }

  func userDidProvide(_ cardInfo: CardIOCreditCardInfo?, in paymentViewController: CardIOPaymentViewController?) {
    if let info = cardInfo {
      setCardParams(
        info.cardNumber,
        expMonth: info.expiryMonth,
        expYear: info.expiryYear,
        cvv: info.cvv
      )
    }

    paymentViewController?.dismiss(animated: true, completion: .none)
  }
}
