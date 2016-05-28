import UIKit
import Firebase

class EditProductViewController: UITableViewController {
  var product: Product?

  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var barcodeTextField: UITextField!
  @IBOutlet var quantityTextField: UITextField!
  @IBOutlet var priceTextField: UITextField!

  @IBAction func cancelTapped(sender: UIBarButtonItem) {
    dismiss()
  }

  @IBAction func doneTapped(sender: UIBarButtonItem) {
    let product = Product(
      id: self.product?.id,
      name: nameTextField.text ?? "",
      barcode: barcodeTextField.text ?? "",
      quantity: Int(quantityTextField.text ?? "") ?? 0,
      price: Float(priceTextField.text ?? "") ?? 0
    )
    Database.save(product)
    dismiss()
  }

  override func viewDidLoad() {
    if let product = product {
      nameTextField.text = product.name
      barcodeTextField.text = product.barcode
      quantityTextField.text = "\(product.quantity)"
      priceTextField.text = "\(product.price)"
    }
    nameTextField.becomeFirstResponder()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "scanBarcodeSegue":
      let navVC = segue.destinationViewController as? UINavigationController
      let vc = navVC?.viewControllers.first as? BarcodeScannerViewController
      vc?.receiveBarcodeCallback = { self.barcodeTextField.text = $0 }
    default: break
    }
  }

  // This can be presented as a modal or within a navigationController, this handles both
  func dismiss() {
    self.navigationController?.popViewControllerAnimated(true)
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension EditProductViewController {
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
}