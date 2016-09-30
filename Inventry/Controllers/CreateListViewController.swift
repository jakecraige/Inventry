import UIKit
import RxSwift
import RxCocoa

struct NewList {
  var products: [ListProduct]
  var users: [PublicUser]

  func contains(user: PublicUser) -> Bool {
    return users.contains(user)
  }

  mutating func toggle(listProduct: ListProduct) {
    if let existingIndex = products.index(of: listProduct) {
      products.remove(at: existingIndex)
    } else {
      products.append(ListProduct(product: listProduct.product, quantity: 1))
    }
  }

  mutating func toggle(user: PublicUser) {
    if let existingIndex = users.index(of: user) {
      users.remove(at: existingIndex)
    } else {
      users.append(user)
    }
  }

  mutating func addOrIncrement(listProduct: ListProduct) {
    if let existingIndex = products.index(of: listProduct) {
      products[existingIndex].quantity += 1
    } else {
      products.append(ListProduct(product: listProduct.product, quantity: 1))
    }
  }

  mutating func removeOrDecrement(listProduct: ListProduct) {
    guard let existingIndex = products.index(of: listProduct) else { return }
    
    let existing = products[existingIndex]
    if existing.quantity <= 1 {
      products.remove(at: existingIndex)
    } else {
      products[existingIndex].quantity -= 1
    }
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

  let products = Variable([ListProduct]())
  let users = Variable([PublicUser]())
  @IBOutlet var segmentedControl: UISegmentedControl!
  @IBOutlet var saveButton: UIBarButtonItem!

  var tableReloaders: Observable<Void> {
    return Observable.combineLatest(
      tableState.asObservable(),
      list.asObservable(),
      products.asObservable()
    ) { _, _, _ in }
  }

  override func viewDidLoad() {
    _ = cancelButton.rx.tap.takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] in self?.dismiss(animated: true, completion: .none) })
    _ = saveButton.rx.tap.takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] in
        print(self?.list.value)
      })

    _ = segmentedControl.rx.value
      .takeUntil(rx.deallocated)
      .map { TableState(rawValue: $0)! }
      .bindTo(tableState)

    _ = tableReloaders.takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] _ in self?.tableView.reloadData() })

    _ = Observable.combineLatest(
      ProductsQuery(user: store.user).build().map({ $0.map { ListProduct(product: $0, quantity: 0) } }),
      list.asObservable().map { $0.products }
    ) { allProducts, selectedProducts in
      return allProducts.reduce([]) { acc, product in
        if let selected = selectedProducts.first(where: { $0 == product}) {
          return acc + [selected]
        } else {
          return acc + [product]
        }
      }
    }.takeUntil(rx.deallocated).bindTo(products)

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
      let listProduct = products.value[indexPath.row]
      cell.textLabel?.text = listProduct.product.name

      if listProduct.quantity > 0 {
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
    case .products: list.value.toggle(listProduct: products.value[indexPath.row])
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
      self.list.value.removeOrDecrement(listProduct: product)
    })
    decrement.backgroundColor = .red

    let increment = UITableViewRowAction(style: .normal, title: "+1", handler: { _, _ in
      self.list.value.addOrIncrement(listProduct: product)
    })
    increment.backgroundColor = .green

    return [increment, decrement]
  }
}
