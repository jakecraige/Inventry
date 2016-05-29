import UIKit
import PromiseKit

struct CancelledAlertError: ErrorType {}

class OrderReviewViewController: UITableViewController {
  @IBOutlet var placeOrderButton: UIBarButtonItem!

  var order: Order!
  var products: [Product] = [] {
    didSet {
      placeOrderButton.enabled = products.count > 0
      viewModel = OrderReviewViewModel(
        order: order,
        products: products
      )
    }
  }
  var viewModel: OrderReviewViewModel? {
    didSet { tableView.reloadData() }
  }

  override func viewDidLoad() {
    Database.observeArrayOnce(eventType: .Value) { self.products = $0 }
  }

  @IBAction func placeOrderTapped(sender: UIBarButtonItem) {
    confirmOkayToChargeCard().then(placeOrder).error { error in
      if error is CancelledAlertError {
        // ignore
      } else {
        print(error)
      }
    }
  }

  private func confirmOkayToChargeCard() -> Promise<Void> {
    return Promise { resolve, reject in
      let amount = PriceFormatter(order.calculateAmount(products)).formatted
      let avc = UIAlertController(
        title: "Confirm Purchase",
        message: "This will charge the credit card \(amount), is that okay?",
        preferredStyle: .Alert
      )
      avc.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { _ in reject(CancelledAlertError()) }))
      avc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in resolve() }))
      
      self.presentViewController(avc, animated: true, completion: nil)
    }
  }

  private func placeOrder() {
    let processor = OrderProcessor(products: products)

    processor.process(order).then { order -> Void in
      print("Order completed: \(order)")
      self.dismissViewControllerAnimated(true, completion: nil)
    }.error { error in
      print("Error encountered: \(error)")
      self.handleProcessError(error)
    }
  }

  private func handleProcessError(error: ErrorType) {
    let avc = UIAlertController(
      title: "Uh oh!",
      message: "We're having trouble placing the order right now. Please try again later.",
      preferredStyle: .Alert
    )
    avc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in }))
    self.presentViewController(avc, animated: true, completion: nil)
  }
}

// MARK: UITableViewDataSource
extension OrderReviewViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.lineItems.count ?? 0
  }
}

// MARK: UITableViewDelegate
extension OrderReviewViewController {
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let viewModel = viewModel else {
      fatalError("We should never reach this when there's no viewModel")
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("orderReviewCell", forIndexPath: indexPath)
    let item = viewModel.lineItem(forIndexPath: indexPath)
    cell.textLabel?.text = item.product.name
    return cell
  }
}
