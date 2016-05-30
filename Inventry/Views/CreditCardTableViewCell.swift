import UIKit
import Stripe

class CreditCardTableViewCell: UITableViewCell {
  let paymentTextField = STPPaymentCardTextField()

  override func awakeFromNib() {
    paymentTextField.translatesAutoresizingMaskIntoConstraints = false
    paymentTextField.borderWidth = 0

    addSubview(paymentTextField)
  }
}
