import UIKit
import Firebase
import RxSwift

class ProductViewController: UIViewController {
  var product: Product!
  var disposeBag = DisposeBag()

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
    Database.observeObject(ref: product.childRef).subscribeNext { [weak self] (product: Product) in
      guard let `self` = self else { return }
      self.product = product
      self.updateUI()
    }.addDisposableTo(disposeBag)
  }

  func updateUI() {
    nameLabel.text = product.name
    barcodeLabel.text = product.barcode
    priceLabel.text = PriceFormatter(product).formatted
    quantityLabel.text = "\(product.quantity)"
  }
}
