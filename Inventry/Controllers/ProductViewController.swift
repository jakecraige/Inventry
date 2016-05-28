import UIKit
import Firebase

class ProductViewController: UIViewController {
  var product: Product!
  var observers: [UInt] = []

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var barcodeLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var quantityLabel: UILabel!

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "editProduct":
      guard let vc = segue.destinationViewController as? EditProductViewController else { return }
      vc.product = product
    default: break
    }
  }

  override func viewDidLoad() {
    observers.append(Database.observeObject(eventType: .Value, ref: product.childRef) { (product: Product) in
      self.product = product
      self.updateUI()
    })
  }

  deinit {
    observers.forEach { Product.ref.removeObserverWithHandle($0) }
  }

  func updateUI() {
    nameLabel.text = product.name
    barcodeLabel.text = product.barcode
    priceLabel.text = "$\(product.price)"
    quantityLabel.text = "\(product.quantity)"
  }
}