import UIKit
import RxSwift

class OrdersTableViewController: UITableViewController {
  var orders: [Order] = [] { didSet { tableView.reloadData() } }
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    store.allOrders
      .subscribe(onNext: { [weak self] in
        self?.orders = $0
      })
      .addDisposableTo(disposeBag)

    // Empty back button for next screen
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }

  @IBAction func unwindToOrders(_ sender: UIStoryboardSegue) {
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "showOrder":
      guard let vc = segue.destination as? OrderReviewViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        else { return }

      // Since we're reusing the review order VC, we want to nil the "Place Order" button and
      // change "Review" title. Note: We're basically abusing this VC and store state
      let order = orders[(indexPath as NSIndexPath).row]
      store.dispatch(SetOrder(order: order))
      vc.navigationItem.rightBarButtonItem = .none
      if let createdAt = order.timestamps?.createdAt {
        vc.navigationItem.title = DateFormatter(createdAt).formatted
      } else {
        vc.navigationItem.title = .none
      }
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension OrdersTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
}

// MARK: UITableViewDelgate
extension OrdersTableViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
    let order = orders[(indexPath as NSIndexPath).row]
    cell.textLabel?.text = order.customer?.name
    if let price = PriceFormatter(order)?.formatted {
      cell.detailTextLabel?.text = price
    } else {
      cell.detailTextLabel?.text = .none
    }
    return cell
  }
}
