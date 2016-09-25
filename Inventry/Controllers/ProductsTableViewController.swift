import UIKit
import Firebase
import RxSwift

class ProductsTableViewController: UITableViewController {
  var groupedProducts: [PublicUser: [Product]] = [:] {
    didSet {
      tableView.reloadData()
    }
  }
  var disposeBag = DisposeBag()

  override func viewDidLoad() {
    ProductsGroupedByUserQuery(user: store.user).build()
      .subscribe(onNext: { [weak self] in
        self?.groupedProducts = $0
      })
      .addDisposableTo(disposeBag)
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
    return groupedProducts.keys.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products(atSection: section).count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell")!

    cell.textLabel?.text = product(atIndexPath: indexPath).name

    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return user(atSection: section).name
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
  func user(atSection section: Int) -> PublicUser {
    return Array(groupedProducts.keys)[section]
  }

  func products(atSection section: Int) -> [Product] {
    return groupedProducts[user(atSection: section)] ?? []
  }

  func product(atIndexPath indexPath: IndexPath) -> Product {
    return groupedProducts[user(atSection: indexPath.section)]![indexPath.row]
  }
}
