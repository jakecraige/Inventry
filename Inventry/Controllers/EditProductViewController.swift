import UIKit
import Firebase
import RxSwift

private enum Cell: Int {
  case name
  case barcode
  case quantity
  case price

  var label: String {
    return "\(self)".capitalizedString
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

  @IBAction func cancelTapped(sender: UIBarButtonItem) {
    dismiss()
  }

  @IBAction func doneTapped(sender: UIBarButtonItem) {
    let price: Cents = Int((Float(self.price ?? "") ?? 0) * 100)
    let product = Product(
      id: self.product?.id,
      name: name ?? "",
      barcode: barcode ?? "",
      quantity: Int(quantity ?? "") ?? 0,
      price: price,
      currency: .USD,
      userId: ""
    )

    if !product.isPersisted {
      Analytics.logEvent(.CreateProduct, [
        kFIRParameterValue: product.price / 100,
        kFIRParameterCurrency: Currency.USD.rawValue,
        kFIRParameterQuantity: product.quantity,
        Analytics.Param.HasBarcode.rawValue: !product.barcode.isEmpty
      ])
    }

    store.dispatch(SaveProduct(product: product)).subscribe().addDisposableTo(disposeBag)
    dismiss()
  }

  override func viewDidLoad() {
    tableView.registerNib(
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

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "scanBarcodeSegue":
      let navVC = segue.destinationViewController as? UINavigationController
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
  private func dismiss() {
    self.navigationController?.popViewControllerAnimated(true)
    dismissViewControllerAnimated(true, completion: nil)
  }

  private func reloadBarcodeCell() {
    let indexPath = NSIndexPath(forRow: Cell.barcode.rawValue, inSection: 0)
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
  }
}

// MARK: UITableViewDataSource
extension EditProductViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfCells
  }
}

// MARK: UITableViewDelegate
extension EditProductViewController {
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cellType = Cell(rawValue: indexPath.row) else { fatalError() }
    let cell = tableView.dequeueReusableCellWithIdentifier("formTextFieldCell", forIndexPath: indexPath) as! FormTextFieldTableViewCell

    switch cellType {
    case .name:
      cell.keyboardType = .Default
      cell.configure(cellType.label, value: name) { [weak self] in self?.name = $0 }
    case .barcode:
      cell.keyboardType = .NumberPad
      cell.configure(cellType.label, value: barcode) { [weak self] in self?.barcode = $0 }
    case .quantity:
      cell.keyboardType = .NumberPad
      cell.configure(cellType.label, value: quantity) { [weak self] in self?.quantity = $0 }
    case .price:
      cell.keyboardType = .DecimalPad
      cell.configure(cellType.label, value: price) { [weak self] in self?.price = $0 }
    }

    return cell
  }
}
