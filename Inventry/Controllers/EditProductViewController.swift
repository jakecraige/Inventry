import UIKit
import Firebase

class EditProductViewController: UITableViewController {
  var product: Product?

  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var isbnTextField: UITextField!
  @IBOutlet var quantityTextField: UITextField!
  @IBOutlet var priceTextField: UITextField!

  @IBAction func cancelTapped(sender: UIBarButtonItem) {
    dismiss()
  }

  @IBAction func doneTapped(sender: UIBarButtonItem) {
    let product = Product(
      id: self.product?.id,
      name: nameTextField.text ?? "",
      isbn: isbnTextField.text ?? "",
      quantity: Int(quantityTextField.text ?? "") ?? 0,
      price: Float(priceTextField.text ?? "") ?? 0
    )
    Database.save(product)
    dismiss()
  }

  override func viewDidLoad() {
    if let product = product {
      nameTextField.text = product.name
      isbnTextField.text = product.isbn
      quantityTextField.text = "\(product.quantity)"
      priceTextField.text = "\(product.price)"
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