import UIKit
import Swish

class OrderReviewViewController: UITableViewController {
  @IBOutlet var placeOrderButton: UIBarButtonItem!

  var order: Order!

  @IBAction func placeOrderTapped(sender: UIBarButtonItem) {
    guard let order = order else { return }

    Database.observeArrayOnce(eventType: .Value) { (products: [Product]) in
      let processor = OrderProcessor(order: order, products: products)

      processor.process().then { order -> Void in
        print("DONE!")
        print(order)
      }.error { error in
        print("ERROR")
        print(error)
      }
    }
  }
}
