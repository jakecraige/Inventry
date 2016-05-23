import UIKit
import Firebase

class ProductsTableViewController: UITableViewController {
  var products: [Product] = [] {
    didSet {
      tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    Product.observeArrayOnce(eventType: .Value) { self.products = $0 }
    Product.observeObject(eventType: .ChildAdded) { [weak self] product in
      self?.products.append(product)
    }
  }
}

// MARK: UITableViewDataSource

extension ProductsTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("productCell")!

    cell.textLabel?.text = products[indexPath.row].name

    return cell
  }
}