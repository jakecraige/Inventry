import UIKit

class OrderChooseProductsTableViewController: UITableViewController {
  var searchQuery: String? { didSet { tableView.reloadData() } }
  var allProducts: [Product] = [] { didSet { tableView.reloadData() } }
  var order = Order.new() {
    didSet {
      tableView.reloadData()
      updateNavigationTitle()
    }
  }
  var observers: [UInt] = []
  let searchController = UISearchController(searchResultsController: nil)

  var filteredProducts: [Product]  {
    if let query = searchQuery where !query.isEmpty {
      return allProducts.filter { $0.name.lowercaseString.containsString(query.lowercaseString) }
    } else {
      return allProducts
    }
  }

  var searchControllerActive: Bool {
    return searchController.active && searchController.searchBar.text != nil
  }

  override func viewDidLoad() {
    observers.append(Database.observeArray(eventType: .Value, orderBy: "name") { [weak self] in
      self?.allProducts = $0
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
    case "paymentSegue":
      let vc = segue.destinationViewController as? OrderPaymentViewController
      vc?.order = order
    case "scanBarcodeSegue":
      let navVC = segue.destinationViewController as? UINavigationController
      let vc = navVC?.viewControllers.first as? BarcodeScannerViewController
      vc?.receiveBarcodeCallback = { self.addOrIncrementProduct(withBarcode: $0) }
    default: break
    }
  }

  private func getProduct(atIndexPath indexPath: NSIndexPath) -> Product {
    return searchControllerActive ? filteredProducts[indexPath.row] : allProducts[indexPath.row]
  }

  private func addOrIncrementProduct(withBarcode barcode: String) {
    if let product = allProducts.find({$0.barcode == barcode}) {
      addOrIncrementProduct(product)
    } else {
      print("Couldn't find product with code: \(barcode)")
    }
  }

  private func addOrIncrementProduct(product: Product) {
    guard product.quantity > 0 else { return }
    guard let productId = product.id else { return }

    if let item = order.item(forProduct: product) {
      guard product.quantity > item.quantity else { return }
      order.increment(lineItem: item)
    } else {
      order.add(lineItem: LineItem(productId: productId))
    }
  }

  private func removeOrDecrement(product: Product) {
    guard let productId = product.id else { return }
    order.removeOrDecrement(lineItem: LineItem(productId: productId))
  }

  private func updateNavigationTitle() {
    let amount = order.calculateAmount(allProducts)
    self.navigationItem.title = PriceFormatter(amount).formatted
  }
}

// MARK: UITableViewDataSource
extension OrderChooseProductsTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchControllerActive {
      return filteredProducts.count
    } else {
      return allProducts.count
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

    if let item = order.item(forProduct: product) {
      order.remove(lineItem: item)
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
