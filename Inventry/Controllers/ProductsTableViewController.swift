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

  @IBOutlet var addButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    ProductsQuery(user: store.user).build()
      .subscribe(onNext: { [weak self] in
        self?.products = $0
      })
      .addDisposableTo(disposeBag)

    tableView.tableFooterView = UIView()
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

      vc.product = product(atIndexPath: indexPath)
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension ProductsTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell")!

    cell.textLabel?.text = product(atIndexPath: indexPath).name

    return cell
  }
}

// MARK: UITableViewDelegate
extension ProductsTableViewController {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if FIRAuth.auth()?.currentUser?.uid == product(atIndexPath: indexPath).userId {
      return .delete
    } else {
      return .none
    }
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      store.dispatch(DeleteProduct(product: product(atIndexPath: indexPath)))
        .subscribe().addDisposableTo(disposeBag)

    default: break
    }
  }
}

private extension ProductsTableViewController {
  func product(atIndexPath indexPath: IndexPath) -> Product {
    return products[indexPath.row]
  }
}
