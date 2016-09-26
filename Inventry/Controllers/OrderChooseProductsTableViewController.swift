import UIKit
import RxSwift

class OrderChooseProductsTableViewController: UITableViewController {
  var searchQuery: String? { didSet { tableView.reloadData() } }
  var viewModel = OrderViewModel.null()
  var order: Order { return viewModel.order }
  let disposeBag = DisposeBag()
  let searchController = UISearchController(searchResultsController: nil)

  var _groupedProducts: [PublicUser: [Product]] = [:] {
    didSet { tableView.reloadData() }
  }
  var filteredGroupedProducts: [PublicUser: [Product]]  {
    if let query = searchQuery, !query.isEmpty {
      return _groupedProducts.reduce([:]) { acc, keyValue in
        let (key, value) = keyValue
        let products = value.filter { $0.name.lowercased().contains(query.lowercased()) }
        return acc + [key: products]
      }
    } else {
      return _groupedProducts
    }
  }
  var products: [Product] {
    return Array(filteredGroupedProducts.map { $0.value }.joined())
  }

  var searchControllerActive: Bool {
    return searchController.isActive && searchController.searchBar.text != nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    store.dispatch(ResetCurrentOrder())

    store.orderViewModel.subscribe(onNext: { [weak self] updatedViewModel in
      guard let `self` = self else { return }
      self.viewModel = updatedViewModel
      self.tableView.reloadData()
      self.updateNavigationTitle()
    }).addDisposableTo(disposeBag)

    ProductsGroupedByUserQuery(user: store.user).build()
      .subscribe(onNext: { [weak self] in
        self?._groupedProducts = $0
      })
      .addDisposableTo(disposeBag)

    definesPresentationContext = true
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search for a product"
    searchController.searchBar.searchBarStyle = .minimal
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar

    // Empty back button for next screen
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    tableView.tableFooterView = UIView()

    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "scanBarcodeSegue":
      let navVC = segue.destination as? UINavigationController
      let vc = navVC?.viewControllers.first as? BarcodeScannerViewController
      vc?.receiveBarcodeCallback = { [weak self] in self?.addOrIncrementProduct(withBarcode: $0) }
    default: break
    }
  }

  fileprivate func addOrIncrementProduct(withBarcode barcode: String) {
    if let product = products.find({$0.barcode == barcode}) {
      addOrIncrementProduct(product)
    } else {
      print("Couldn't find product with code: \(barcode)")
    }
  }

  fileprivate func addOrIncrementProduct(_ product: Product) {
    guard product.quantity > 0 else { return }

    if let item = order.item(forProduct: product) {
      guard product.quantity > item.quantity else { return }
      store.dispatch(IncrementCurrentOrder(lineItem: item))
    } else {
      store.dispatch(AddToCurrentOrder(product: product))
    }
  }

  fileprivate func removeOrDecrement(_ product: Product) {
    store.dispatch(DecrementFromCurrentOrder(product: product))
  }

  fileprivate func updateNavigationTitle() {
    self.navigationItem.title = PriceFormatter(viewModel.subtotal).formatted
  }
}

// MARK: UITableViewDataSource
extension OrderChooseProductsTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return filteredGroupedProducts.keys.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return products(atSection: section).count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return user(atSection: section).name
  }
}

// MARK: UITableViewDelegate
extension OrderChooseProductsTableViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let product = self.product(atIndexPath: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! SelectProductTableViewCell
    cell.configure(forOrder: order, product: product)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let product = self.product(atIndexPath: indexPath)

    if let _ = order.item(forProduct: product) {
      store.dispatch(RemoveFromCurrentOrder(product: product))
    } else {
      addOrIncrementProduct(product)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let product = self.product(atIndexPath: indexPath)

    let decrement = UITableViewRowAction(style: .normal, title: "-1", handler: { _, _ in
      self.removeOrDecrement(product)
    })
    decrement.backgroundColor = .red

    let increment = UITableViewRowAction(style: .normal, title: "+1", handler: { _, _ in
      self.addOrIncrementProduct(product)
    })
    increment.backgroundColor = .green

    return [increment, decrement]
  }
}

extension OrderChooseProductsTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    searchQuery = searchController.searchBar.text
  }
}

// MARK: UIViewControllerPreviewingDelegate
extension OrderChooseProductsTableViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let indexPath = tableView.indexPathForRow(at: location),
          let vc = UIStoryboard.instantiateViewController(withIdentifier: "ViewProduct", fromStoryboard: .Main) as? ProductViewController
      else { return .none }

    vc.product = product(atIndexPath: indexPath)

    return vc
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    // Purposely empty since this never gets called because we only do a preview
  }
}

private extension OrderChooseProductsTableViewController {
  func user(atSection section: Int) -> PublicUser {
    return Array(filteredGroupedProducts.keys)[section]
  }

  func products(atSection section: Int) -> [Product] {
    return filteredGroupedProducts[user(atSection: section)] ?? []
  }

  func product(atIndexPath indexPath: IndexPath) -> Product {
    return filteredGroupedProducts[user(atSection: indexPath.section)]![indexPath.row]
  }
}
