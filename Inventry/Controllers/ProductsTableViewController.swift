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
    store.allProducts.subscribe(onNext: { [weak self] in
      self?.products = $0
    }).addDisposableTo(disposeBag)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier
      else { return }

    switch identifier {
    case "viewProduct":
      guard let vc = segue.destination as? ProductViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        else { return }

      vc.product = products[(indexPath as NSIndexPath).row]
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension ProductsTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell")!

    cell.textLabel?.text = products[(indexPath as NSIndexPath).row].name

    return cell
  }
}

// MARK: UITableViewDelegate
extension ProductsTableViewController {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      store.dispatch(DeleteProduct(product: products[indexPath.row]))
        .subscribe().addDisposableTo(disposeBag)

    default: break
    }
  }
}
