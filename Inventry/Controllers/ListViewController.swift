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

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "showListProducts":
      let vc = segue.destination as! ListProductsViewController
      vc.configure(list: list.value)
      
    default: break
    }
  }

  func updateView(list: List) {
    title = list.name
  }
}
