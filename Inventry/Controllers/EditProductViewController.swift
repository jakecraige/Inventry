import UIKit
import Firebase
import RxSwift

private enum Cell: Int {
  case name
  case barcode
  case quantity
  case price

  var label: String {
    return "\(self)".capitalized
  }
}
private let numberOfCells = 4

class EditProductViewController: UITableViewController {
  var product: Product?
  var name: String?
  var barcode: String?
  var quantity: String?
  var price: String?
  let disposeBag = DisposeBag()

  @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
    dismiss()
  }

  @IBAction func doneTapped(_ sender: UIBarButtonItem) {
    let price: Cents = Int((Float(self.price ?? "") ?? 0) * 100)
    let product = Product(
      id: self.product?.id,
      name: name ?? "",
      barcode: barcode ?? "",
      quantity: Int(quantity ?? "") ?? 0,
      price: price,
      currency: .USD,
      userId: self.product?.userId ?? ""
    )

    if !product.isPersisted {
      Analytics.logEvent(.CreateProduct, [
        kFIRParameterValue: (product.price / 100) as AnyObject,
        kFIRParameterCurrency: Currency.USD.rawValue as AnyObject,
        kFIRParameterQuantity: product.quantity as AnyObject,
        Analytics.Param.HasBarcode.rawValue: !product.barcode.isEmpty as AnyObject
      ])
    }

    store.dispatch(SaveProduct(product: product)).subscribe().addDisposableTo(disposeBag)
    dismiss()
  }

  override func viewDidLoad() {
    tableView.register(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )
    if let product = product {
      name = product.name
      barcode = product.barcode
      quantity = "\(product.quantity)"
      price = "\(PriceFormatter(product).dollarPrice)"
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "scanBarcodeSegue":
      let navVC = segue.destination as? UINavigationController
      let vc = navVC?.viewControllers.first as? BarcodeScannerViewController
      vc?.receiveBarcodeCallback = { [weak self] code in
        guard let `self` = self else { return }
        self.barcode = code
        self.reloadBarcodeCell()
      }
    default: break
    }
  }

  // This can be presented as a modal or within a navigationController, this handles both
  fileprivate func dismiss() {
    _ = navigationController?.popViewController(animated: true)
    dismiss(animated: true, completion: nil)
  }

  fileprivate func reloadBarcodeCell() {
    let indexPath = IndexPath(row: Cell.barcode.rawValue, section: 0)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
}

// MARK: UITableViewDataSource
extension EditProductViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfCells
  }
}

// MARK: UITableViewDelegate
extension EditProductViewController {
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cellType = Cell(rawValue: (indexPath as NSIndexPath).row) else { fatalError() }
    let cell = tableView.dequeueReusableCell(withIdentifier: "formTextFieldCell", for: indexPath) as! FormTextFieldTableViewCell

    switch cellType {
    case .name:
      cell.keyboardType = .default
      cell.configure(cellType.label, value: name) { [weak self] in self?.name = $0 }
    case .barcode:
      cell.keyboardType = .numberPad
      cell.configure(cellType.label, value: barcode) { [weak self] in self?.barcode = $0 }
    case .quantity:
      cell.keyboardType = .numberPad
      cell.configure(cellType.label, value: quantity) { [weak self] in self?.quantity = $0 }
    case .price:
      cell.keyboardType = .decimalPad
      cell.configure(cellType.label, value: price) { [weak self] in self?.price = $0 }
    }

    return cell
  }
}
