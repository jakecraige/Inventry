import UIKit

class OrdersTableViewController: UITableViewController {
  var orders: [Order] = [] { didSet { tableView.reloadData() } }
  var observers: [UInt] = []

  override func viewDidLoad() {
    AuthenticationController().present(onViewController: self)

    observers.append(Database.observeArray(eventType: .Value) { [weak self] in self?.orders = $0 })
  }

  deinit {
    observers.forEach { Order.ref.removeObserverWithHandle($0) }
  }

  @IBAction func unwindToOrders(sender: UIStoryboardSegue) {
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "showOrder":
      guard let vc = segue.destinationViewController as? OrderReviewViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPathForCell(cell)
        else { return }

      vc.order = orders[indexPath.row]
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension OrdersTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
}

// MARK: UITableViewDelgate
extension OrdersTableViewController {
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("orderCell", forIndexPath: indexPath)
    let order = orders[indexPath.row]
    cell.textLabel?.text = order.customer?.name
    if let price = PriceFormatter(order)?.formatted {
      cell.detailTextLabel?.text = price
    } else {
      cell.detailTextLabel?.text = .None
    }
    return cell
  }
}
