import UIKit
import Swish

class OrderReviewViewController: UITableViewController {
  @IBOutlet var placeOrderButton: UIBarButtonItem!

  var order: Order!

  @IBAction func placeOrderTapped(sender: UIBarButtonItem) {
    guard let paymentToken = order.paymentToken else { return }

    let request = ProcessPaymentRequest(amount: 500, description: "order", token: paymentToken)
    APIClient().performRequest(request).then {
      print("DONE!")
    }.error { error in
      print("ERROR")
      print(error)
    }
  }
}
