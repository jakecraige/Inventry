import UIKit
import Firebase
import RxSwift

private enum ViewState: Int {
  case lists
  case inventory
}

class ProductsTableViewController: UITableViewController {
  var groupedProducts: [PublicUser: [Product]] = [:] {
    didSet {
      tableView.reloadData()
    }
  }
  var disposeBag = DisposeBag()
  fileprivate var viewState = Variable(ViewState.lists)

  @IBOutlet var segmentedControl: UISegmentedControl!
  @IBOutlet var addButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()

    ProductsGroupedByUserQuery(user: store.user).build()
      .subscribe(onNext: { [weak self] in
        self?.groupedProducts = $0
      })
      .addDisposableTo(disposeBag)

    segmentedControl.rx.value
      .map { ViewState(rawValue: $0)! }
      .bindTo(viewState)
      .addDisposableTo(disposeBag)

    viewState.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .addDisposableTo(disposeBag)

    addButton.rx.tap
        .subscribe(onNext: { [weak self] in
          guard let `self` = self else { return }
          switch self.viewState.value {
          case .lists:
            self.performSegue(withIdentifier: "addList", sender: self)
          case .inventory:
            self.performSegue(withIdentifier: "addProduct", sender: self)
          }
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
    switch viewState.value {
    case .lists:
      return 0
    case .inventory:
      return groupedProducts.keys.count
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch viewState.value {
    case .lists:
      return 0
    case .inventory:
      return products(atSection: section).count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell")!

    cell.textLabel?.text = product(atIndexPath: indexPath).name

    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch viewState.value {
    case .lists:
      return .none
    case .inventory:
      return user(atSection: section).name
    }
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
