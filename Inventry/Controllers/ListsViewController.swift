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

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    guard let list: List = try? tableView.rx.model(indexPath) else { return [] }
    
    let action = UITableViewRowAction(style: .destructive, title: "Delete") { _, _ in
      _ = store.dispatch(DeleteList(list: list)).takeUntil(self.rx.deallocated).subscribe()
    }
    return [action]
  }
}