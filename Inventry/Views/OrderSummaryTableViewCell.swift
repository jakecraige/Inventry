import UIKit

class OrderSummaryTableViewCell: UITableViewCell {
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var phoneLabel: UILabel!
  @IBOutlet var emailLabel: UILabel!
  @IBOutlet var subtotalLabel: UILabel!
  @IBOutlet var taxLabel: UILabel!
  @IBOutlet var totalLabel: UILabel!

  func configure(viewModel: OrderViewModel) {
    nameLabel.text = viewModel.customer?.name
    phoneLabel.text = viewModel.customer?.phone
    emailLabel.text = viewModel.customer?.email
    subtotalLabel.text = PriceFormatter(viewModel.subtotal).formatted
    taxLabel.text = PriceFormatter(viewModel.tax).formatted
    totalLabel.text = PriceFormatter(viewModel.total).formatted
  }
}
