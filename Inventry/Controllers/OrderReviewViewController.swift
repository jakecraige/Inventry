import UIKit
import PromiseKit
import RxSwift

private enum Section: Int {
  case lineItems
  case settings
  case summary
}
private let sectionCount = 3

private enum SettingsCell: Int {
  case taxRate
  case shippingRate
  case notes
}

class OrderReviewViewController: UITableViewController {
  @IBOutlet var nextButton: UIBarButtonItem!

  let disposeBag = DisposeBag()
  var viewModel = OrderViewModel.null() {
    didSet {
      nextButton.isEnabled = viewModel.products.count > 0
      let oldOrder = oldValue.order
      let newOrder = viewModel.order

      // Efficiently reload relevant cells when specific values change. This is kind of gross though.
      // It also prevents losing focus since `tableView.reloadData` reloads the settings cells too
      // and causes you to lose focus
      if oldOrder.taxRate != newOrder.taxRate {
        tableView.reloadRows(
          at: [
            IndexPath(row: SettingsCell.taxRate.rawValue, section: Section.settings.rawValue),
            IndexPath(row: 0, section: Section.summary.rawValue)
          ],
          with: .automatic
        )
      } else if oldOrder.shippingRate != newOrder.shippingRate {
        tableView.reloadRows(
          at: [
            IndexPath(row: SettingsCell.taxRate.rawValue, section: Section.settings.rawValue),
            IndexPath(row: 0, section: Section.summary.rawValue)
          ],
          with: .automatic
        )
      } else if oldOrder.notes != newOrder.notes {
        tableView.reloadRows(
          at: [IndexPath(row: SettingsCell.notes.rawValue, section: Section.settings.rawValue)],
          with: .automatic
        )
      } else {
        tableView.reloadData()
      }
    }
  }

  override func viewDidLoad() {
    store.orderViewModel.subscribe(onNext: { [weak self] in
      self?.viewModel = $0
    }).addDisposableTo(disposeBag)

    tableView.register(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "paymentSegue":
      let vc = segue.destination as? OrderPaymentViewController
      vc?.viewModel = viewModel
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension OrderReviewViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sectionCount
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = Section(rawValue: section) else { return 0 }

    switch section {
    case .lineItems: return viewModel.lineItems.count
    case .settings: return 3
    case .summary: return 1
    }
  }
}

// MARK: UITableViewDelegate
extension OrderReviewViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let section = Section(rawValue: (indexPath as NSIndexPath).section) else { fatalError("Unknown section") }

    switch section {
    case .lineItems:
      let cell = tableView.dequeueReusableCell(withIdentifier: "orderReviewCell", for: indexPath) as! OrderReviewTableViewCell
      let item = viewModel.lineItem(forIndexPath: indexPath)
      cell.configure(item)
      return cell

    case .settings:
      guard let cellType = SettingsCell(rawValue: (indexPath as NSIndexPath).row) else { fatalError() }
      let cell = tableView.dequeueReusableCell(withIdentifier: "formTextFieldCell", for: indexPath) as! FormTextFieldTableViewCell

      switch cellType {
      case .taxRate:
        cell.keyboardType = .decimalPad
        cell.configure("Tax Rate %", value: "\(viewModel.order.taxRate * 100)", changeEvent: .editingDidEnd) { newValue in
          if let value = Float(newValue ?? "") {
            store.dispatch(UpdateCurrentOrder(taxRate: value / 100))
          }
        }
      case .shippingRate:
        cell.keyboardType = .decimalPad
        cell.configure("Shipping %", value: "\(viewModel.order.shippingRate * 100)", changeEvent: .editingDidEnd) { newValue in
          if let value = Float(newValue ?? "") {
            store.dispatch(UpdateCurrentOrder(shippingRate: value / 100))
          }
        }
      case .notes:
        cell.keyboardType = .default
        cell.configure("Notes", value: viewModel.order.notes, changeEvent: .editingDidEnd) { newValue in
          store.dispatch(UpdateCurrentOrder(notes: newValue))
        }
      }

      return cell

    case .summary:
      let cell = tableView.dequeueReusableCell(withIdentifier: "orderSummaryCell", for: indexPath) as! OrderSummaryTableViewCell
      cell.configure(viewModel)
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let section = Section(rawValue: (indexPath as NSIndexPath).section) else { return 44 }

    switch section {
    case .lineItems, .settings: return 44
    case .summary: return UITableViewAutomaticDimension
    }
  }
}
