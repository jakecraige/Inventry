import UIKit

class OrderChooseProductsTableViewController: UITableViewController {
  var searchQuery: String? { didSet { tableView.reloadData() } }
  var allProducts: [Product] = [] { didSet { tableView.reloadData() } }
  var order = Order.new() { didSet { tableView.reloadData() } }
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
    observers.append(Database.observeArray(eventType: .Value) { [weak self] (products: [Product]) in
      self?.allProducts = products
    })

    definesPresentationContext = true
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search for a product"
    searchController.searchBar.searchBarStyle = .Minimal
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar

    // Empty back button for next screen
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
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
    default: break
    }
  }

  @IBAction func unwindToChooseProducts(segue: UIStoryboardSegue) {
    switch segue.sourceViewController {
    case let vc as BarcodeScannerViewController:
      if let barcode = vc.scannedBarcode {
        addProduct(withBarcode: barcode)
      }
    default: break
    }
  }

  private func getProduct(atIndexPath indexPath: NSIndexPath) -> Product {
    return searchControllerActive ? filteredProducts[indexPath.row] : allProducts[indexPath.row]
  }

  private func addProduct(withBarcode barcode: String) {
    let product = allProducts.filter { $0.isbn == barcode }.first
    if let product = product {
      addProduct(product)
    } else {
      print("Couldn't find product with code: \(barcode)")
    }
  }

  private func addProduct(product: Product) {
    guard let productId = product.id else { return }
    let lineItem = LineItem(productId: productId)
    order.add(lineItem: lineItem)
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
    let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath)
    let product = getProduct(atIndexPath: indexPath)
    cell.textLabel?.text = product.name
    
    if let productId = product.id where order.contains(LineItem(productId: productId)) {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let product = getProduct(atIndexPath: indexPath)
    guard let productId = product.id else { return }
    let lineItem = LineItem(productId: productId)
    
    if order.contains(lineItem) {
      order.remove(lineItem: lineItem)
    } else {
      addProduct(product)
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

extension OrderChooseProductsTableViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    searchQuery = searchController.searchBar.text
  }
}
