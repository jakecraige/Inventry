import UIKit

class OrderReviewTableViewCell: UITableViewCell {
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var quantityLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!

  func configure(_ vm: LineItemViewModel) {
    nameLabel.text = vm.name
    quantityLabel.text = "Qty: \(vm.quantity)"
    priceLabel.text = vm.formattedPrice
  }
}
