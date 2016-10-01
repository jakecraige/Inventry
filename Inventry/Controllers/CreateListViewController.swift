import UIKit
import RxSwift
import RxCocoa

struct NewList {
  var products: [ListProduct]
  var users: [PublicUser]

  func contains(user: PublicUser) -> Bool {
    return users.contains(user)
  }
  
  func first(product: Product) -> ListProduct? {
    return index(of: product).flatMap { products[$0] }
  }

  mutating func toggle(product: Product) {
    if let existingIndex = index(of: product) {
      products.remove(at: existingIndex)
    } else {
      products.append(ListProduct(product: product, quantity: 1))
    }
  }

  mutating func toggle(user: PublicUser) {
    if let existingIndex = users.index(of: user) {
      users.remove(at: existingIndex)
    } else {
      users.append(user)
    }
  }

  mutating func addOrIncrement(product: Product) {
    if let existingIndex = index(of: product) {
      products[existingIndex].quantity += 1
    } else {
      products.append(ListProduct(product: product, quantity: 1))
    }
  }

  mutating func removeOrDecrement(product: Product) {
    guard let existingIndex = index(of: product) else { return }

    let existing = products[existingIndex]
    if existing.quantity <= 1 {
      products.remove(at: existingIndex)
    } else {
      products[existingIndex].quantity -= 1
    }
  }

  func index(of product: Product) -> Int? {
    return products.map { $0.product }.index(of: product)
  }
}

struct ListProduct {
  let product: Product
  var quantity: Int
}

extension ListProduct: Equatable {
  static func == (lhs: ListProduct, rhs: ListProduct) -> Bool {
    return lhs.product == rhs.product
  }
}

private enum TableState: Int {
  case products
  case users
}

final class CreateListChooseProductsViewController: UITableViewController {
  @IBOutlet var cancelButton: UIBarButtonItem!

  var list = Variable(NewList(products: [], users: []))
  private var tableState = Variable(TableState.products)

  let products = Variable([Product]())
  let users = Variable([PublicUser]())
  @IBOutlet var segmentedControl: UISegmentedControl!
  @IBOutlet var saveButton: UIBarButtonItem!

  var tableReloaders: Observable<Void> {
    return Observable.combineLatest(
      tableState.asObservable(),
      list.asObservable(),
      products.asObservable(),
      users.asObservable()
    ) { _, _, _, _ in }
  }

  override func viewDidLoad() {
    _ = cancelButton.rx.tap.takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] in self?.dismiss(animated: true, completion: .none) })
    _ = saveButton.rx.tap.takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] in self?.saveList() })

    _ = segmentedControl.rx.value
      .takeUntil(rx.deallocated)
      .map { TableState(rawValue: $0)! }
      .bindTo(tableState)

    _ = tableReloaders.takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] _ in self?.tableView.reloadData() })

    _ = ProductsQuery(user: store.user).build().takeUntil(rx.deallocated).bindTo(products)
    _ = PublicUsersQuery().build().takeUntil(rx.deallocated).bindTo(users)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tableState.value {
    case .products: return products.value.count
    case .users: return users.value.count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)

    switch tableState.value {
    case .products:
      let product = products.value[indexPath.row]
      cell.textLabel?.text = product.name

      if let listProduct = list.value.first(product: product) {
        cell.detailTextLabel?.text = "Quantity: \(listProduct.quantity)"
        cell.accessoryType = .checkmark
      } else {
        cell.detailTextLabel?.text = .none
        cell.accessoryType = .none
      }
    case .users:
      let user = users.value[indexPath.row]
      cell.textLabel?.text = user.name
      cell.detailTextLabel?.text = .none
      cell.accessoryType = list.value.contains(user: user) ? .checkmark : .none
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch tableState.value {
    case .products: list.value.toggle(product: products.value[indexPath.row])
    case .users: list.value.toggle(user: users.value[indexPath.row])
    }
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    guard tableState.value == .products else { return false }
    return products.value[indexPath.row].quantity > 0
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let product = products.value[indexPath.row]

    let decrement = UITableViewRowAction(style: .normal, title: "-1", handler: { _, _ in
      self.list.value.removeOrDecrement(product: product)
    })
    decrement.backgroundColor = .red

    let increment = UITableViewRowAction(style: .normal, title: "+1", handler: { _, _ in
      self.list.value.addOrIncrement(product: product)
    })
    increment.backgroundColor = .green

    return [increment, decrement]
  }
}

extension CreateListChooseProductsViewController {
  func saveList() {
    let alert = UIAlertController(
      title: "Name your list",
      message: "What do you want to name this list?",
      preferredStyle: .alert
    )
    alert.addTextField { $0.placeholder = "List name" }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
    alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
      let textField = alert.textFields![0]
      print("Create with name", textField.text)
    }))
    present(alert, animated: true, completion: .none)
  }
}
