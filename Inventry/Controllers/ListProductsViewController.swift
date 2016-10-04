import UIKit
import RxSwift
import RxCocoa

final class ListProductsViewController: UITableViewController {
  let list = Variable<List!>(.none)
  let products = Variable([PopulatedListProduct]())

  func configure(list: List) {
    self.list.value = list
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    tableView.dataSource = .none

    _ = list.asObservable()
      .flatMap { ListProductsQuery(list: $0).build() }
      .takeUntil(rx.deallocated)
      .bindTo(products)

    _ = products.asObservable()
      .takeUntil(rx.deallocated)
      .bindTo(tableView.rx.items(cellIdentifier: "productCell", cellType: UITableViewCell.self)) { _, product, cell in
        cell.textLabel?.text = product.product.name
        cell.detailTextLabel?.text = "Quantity: \(product.quantity)"
      }
  }
}
