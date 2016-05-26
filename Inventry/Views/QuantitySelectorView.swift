import UIKit

class QuantitySelectorView: UIView {
  var quantity: Int = 0 {
    didSet {
      quantityLabel.text = "\(quantity)"
    }
  }

  @IBOutlet var quantityLabel: UILabel!

  @IBAction func decrementTapped(sender: UIButton) {
    quantity -= 1
  }

  @IBAction func incrementTapped(sender: UIButton) {
    quantity += 2
  }
}