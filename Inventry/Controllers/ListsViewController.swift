import UIKit
import RxSwift
import RxCocoa

final class ListsViewController: UITableViewController {
  var lists = Variable([List]())

  override func viewDidLoad() {
    tableView.dataSource = .none
    tableView.tableFooterView = UIView()

    _ = ListsQuery(user: store.user).build().takeUntil(rx.deallocated).bindTo(lists)

    _ = lists.asObservable()
      .takeUntil(rx.deallocated)
      .bindTo(tableView.rx.items(cellIdentifier: "listCell", cellType: UITableViewCell.self)) { _, list, cell in
        cell.textLabel?.text = list.name
      }
  }
}
