import UIKit
import RxSwift
import RxCocoa

final class ListUsersViewController: UITableViewController {
  let list = Variable<List!>(.none)
  let users = Variable([PublicUser]())

  func configure(list: List) {
    self.list.value = list
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    tableView.dataSource = .none

    _ = list.asObservable()
      .flatMap { ListUsersQuery(list: $0).build() }
      .takeUntil(rx.deallocated)
      .bindTo(users)

    _ = users.asObservable()
      .takeUntil(rx.deallocated)
      .bindTo(tableView.rx.items(cellIdentifier: "userCell", cellType: UITableViewCell.self)) { _, user, cell in
        cell.textLabel?.text = user.name
      }
  }
}
