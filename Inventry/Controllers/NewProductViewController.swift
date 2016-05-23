import UIKit
import Firebase

class NewProductViewController: UITableViewController {
  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var isbnTextField: UITextField!
  @IBOutlet var quantityTextField: UITextField!
  @IBOutlet var priceTextField: UITextField!

  @IBAction func cancelTapped(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func doneTapped(sender: UIBarButtonItem) {
    let product = Product(
      name: nameTextField.text ?? "",
      isbn: isbnTextField.text ?? "",
      quantity: Int(quantityTextField.text ?? "") ?? 0,
      price: Float(priceTextField.text ?? "") ?? 0
    )
    Product.create(product)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension NewProductViewController {
  override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
}