import UIKit
import RxSwift

class OrderChooseProductsTableViewController: UITableViewController {
  var searchQuery: String? { didSet { tableView.reloadData() } }
  var viewModel = OrderViewModel.null()
  var products: [Product] { return viewModel.products }
  var order: Order { return viewModel.order }
  var observers: [UInt] = []
  let disposeBag = DisposeBag()
  let searchController = UISearchController(searchResultsController: nil)

  var filteredProducts: [Product]  {
    if let query = searchQuery where !query.isEmpty {
      return products.filter { $0.name.lowercaseString.containsString(query.lowercaseString) }
    } else {
      return products
    }
  }

  var searchControllerActive: Bool {
    return searchController.active && searchController.searchBar.text != nil
  }

  override func viewDidLoad() {
    store.dispatch(ResetCurrentOrder())
    observers.append(Database.observeArray(eventType: .Value, orderBy: "name") {
      store.dispatch(SetAllProducts(products: $0))
    })

    disposeBag.addDisposable(store.orderViewModel.subscribeNext { [weak self] updatedViewModel in
      guard let `self` = self else { return }
      self.viewModel = updatedViewModel
      self.tableView.reloadData()
      self.updateNavigationTitle()
    })


    definesPresentationContext = true
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search for a product"
    searchController.searchBar.searchBarStyle = .Minimal
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar

    // Empty back button for next screen
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

    if traitCollection.forceTouchCapability == .Available {
      registerForPreviewingWithDelegate(self, sourceView: tableView)
    }
  }

  deinit {
    observers.forEach { Product.ref.removeObserverWithHandle($0) }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "scanBarcodeSegue":
      let navVC = segue.destinationViewController as? UINavigationController
      let vc = navVC?.viewControllers.first as? BarcodeScannerViewController
      vc?.receiveBarcodeCallback = { [weak self] in self?.addOrIncrementProduct(withBarcode: $0) }
    default: break
    }
  }

  private func getProduct(atIndexPath indexPath: NSIndexPath) -> Product {
    return searchControllerActive ? filteredProducts[indexPath.row] : products[indexPath.row]
  }

  private func addOrIncrementProduct(withBarcode barcode: String) {
    if let product = products.find({$0.barcode == barcode}) {
      addOrIncrementProduct(product)
    } else {
      print("Couldn't find product with code: \(barcode)")
    }
  }

  private func addOrIncrementProduct(product: Product) {
    guard product.quantity > 0 else { return }

    if let item = order.item(forProduct: product) {
      guard product.quantity > item.quantity else { return }
      store.dispatch(IncrementCurrentOrder(lineItem: item))
    } else {
      store.dispatch(AddToCurrentOrder(product: product))
    }
  }

  private func removeOrDecrement(product: Product) {
    store.dispatch(DecrementFromCurrentOrder(product: product))
  }

  private func updateNavigationTitle() {
    self.navigationItem.title = PriceFormatter(viewModel.subtotal).formatted
  }
}

// MARK: UITableViewDataSource
extension OrderChooseProductsTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchControllerActive {
      return filteredProducts.count
    } else {
      return products.count
    }
  }
}

// MARK: UITableViewDelegate
extension OrderChooseProductsTableViewController {
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let product = getProduct(atIndexPath: indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! SelectProductTableViewCell
    cell.configure(forOrder: order, product: product)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let product = getProduct(atIndexPath: indexPath)

    if let _ = order.item(forProduct: product) {
      store.dispatch(RemoveFromCurrentOrder(product: product))
    } else {
      addOrIncrementProduct(product)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let product = getProduct(atIndexPath: indexPath)

    let decrement = UITableViewRowAction(style: .Normal, title: "-1", handler: { _, _ in
      self.removeOrDecrement(product)
    })
    decrement.backgroundColor = .redColor()

    let increment = UITableViewRowAction(style: .Normal, title: "+1", handler: { _, _ in
      self.addOrIncrementProduct(product)
    })
    increment.backgroundColor = .greenColor()

    return [increment, decrement]
  }
}

extension OrderChooseProductsTableViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    searchQuery = searchController.searchBar.text
  }
}

// MARK: UIViewControllerPreviewingDelegate
extension OrderChooseProductsTableViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let indexPath = tableView.indexPathForRowAtPoint(location),
          let vc = UIStoryboard.instantiateViewController(withIdentifier: "ViewProduct", fromStoryboard: .Main) as? ProductViewController
      else { return .None }

    vc.product = getProduct(atIndexPath: indexPath)

    return vc
  }

  func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
    // Purposely empty since this never gets called because we only do a preview
  }
}
