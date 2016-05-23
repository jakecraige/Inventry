import UIKit
import Firebase

class ProductsTableViewController: UITableViewController {
  var products: [Product] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  var observers: [UInt] = []

  override func viewDidLoad() {
    Product.observeArrayOnce(eventType: .Value) { self.products = $0 }
    observers.append(Product.observeObject(eventType: .ChildAdded) { [weak self] product in
      self?.products.append(product)
    })
    observers.append(Product.observeObject(eventType: .ChildChanged) { [weak self] updatedProduct in
      self?.products = (self?.products ?? []).map { product in
        if product.id == updatedProduct.id {
          return updatedProduct
        } else {
          return product
        }
      }
    })
  }

  deinit {
    observers.forEach { Product.ref.removeObserverWithHandle($0) }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier,
          let indexPath = sender as? NSIndexPath
      else { return }

    switch identifier {
    case "viewProduct":
      guard let vc = segue.destinationViewController as? ProductViewController
        else { return }

      vc.product = products[indexPath.row]
    default: break
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

// MARK: UITableViewDelegate
extension ProductsTableViewController {
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("viewProduct", sender: indexPath)
  }
}