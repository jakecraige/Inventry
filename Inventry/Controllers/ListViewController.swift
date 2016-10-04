import UIKit
import RxSwift
import RxCocoa

final class ListViewController: UITableViewController {
  let list = Variable<List!>(.none)

  func configure(list: List) {
    self.list.value = list
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()

    _ = list.asObservable()
      .flatMap { Database.observe(model: $0) }
      .takeUntil(rx.deallocated)
      .subscribe(onNext: { [weak self] updatedList in
        self?.updateView(list: updatedList)
      })
  }

  func updateView(list: List) {
    title = list.name
  }
}
