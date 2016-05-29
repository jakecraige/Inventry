import UIKit

class OrderSummaryTableViewCell: UITableViewCell {
  @IBOutlet var subtotalLabel: UILabel!
  @IBOutlet var taxLabel: UILabel!
  @IBOutlet var totalLabel: UILabel!

  func configure(viewModel: OrderViewModel) {
    subtotalLabel.text = PriceFormatter(viewModel.subtotal).formatted
    taxLabel.text = PriceFormatter(viewModel.tax).formatted
    totalLabel.text = PriceFormatter(viewModel.total).formatted
  }
}
