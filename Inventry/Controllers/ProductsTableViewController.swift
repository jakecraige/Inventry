import UIKit
import Firebase
import RxSwift

class ProductsTableViewController: UITableViewController {
  var products: [Product] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  var disposeBag = DisposeBag()

  override func viewDidLoad() {
    store.allProducts.subscribeNext { [weak self] in
      self?.products = $0
    }.addDisposableTo(disposeBag)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier
      else { return }

    switch identifier {
    case "viewProduct":
      guard let vc = segue.destinationViewController as? ProductViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPathForCell(cell)
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
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    switch editingStyle {
    case .Delete:
      store.dispatch(DeleteProduct(product: products[indexPath.row]))
        .subscribe().addDisposableTo(disposeBag)

    default: break
    }
  }
}