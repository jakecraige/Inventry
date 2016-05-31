import UIKit
import PromiseKit

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

  var viewModel = OrderViewModel.null() {
    didSet {
      nextButton.enabled = viewModel.products.count > 0
      let oldOrder = oldValue.order
      let newOrder = viewModel.order

      // Efficiently reload relevant cells when specific values change. This is kind of gross though.
      // It also prevents losing focus since `tableView.reloadData` reloads the settings cells too
      // and causes you to lose focus
      if oldOrder.taxRate != newOrder.taxRate {
        tableView.reloadRowsAtIndexPaths(
          [
            NSIndexPath(forRow: SettingsCell.taxRate.rawValue, inSection: Section.settings.rawValue),
            NSIndexPath(forRow: 0, inSection: Section.summary.rawValue)
          ],
          withRowAnimation: .Automatic
        )
      } else if oldOrder.shippingRate != newOrder.shippingRate {
        tableView.reloadRowsAtIndexPaths(
          [
            NSIndexPath(forRow: SettingsCell.taxRate.rawValue, inSection: Section.settings.rawValue),
            NSIndexPath(forRow: 0, inSection: Section.summary.rawValue)
          ],
          withRowAnimation: .Automatic
        )
      } else if oldOrder.notes != newOrder.notes {
        tableView.reloadRowsAtIndexPaths(
          [NSIndexPath(forRow: SettingsCell.notes.rawValue, inSection: Section.settings.rawValue)],
          withRowAnimation: .Automatic
        )
      } else {
        tableView.reloadData()
      }
    }
  }

  override func viewDidLoad() {
    if viewModel.products.isEmpty {
      Database.observeArrayOnce(eventType: .Value) { [weak self] (products: [Product]) in
        guard let `self` = self else { return }
        self.viewModel = OrderViewModel(order: self.viewModel.order, products: products)
      }
    }

    tableView.registerNib(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "paymentSegue":
      let vc = segue.destinationViewController as? OrderPaymentViewController
      vc?.viewModel = viewModel
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension OrderReviewViewController {
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionCount
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }

    switch section {
    case .lineItems:
      let cell = tableView.dequeueReusableCellWithIdentifier("orderReviewCell", forIndexPath: indexPath) as! OrderReviewTableViewCell
      let item = viewModel.lineItem(forIndexPath: indexPath)
      cell.configure(item)
      return cell

    case .settings:
      guard let cellType = SettingsCell(rawValue: indexPath.row) else { fatalError() }
      let cell = tableView.dequeueReusableCellWithIdentifier("formTextFieldCell", forIndexPath: indexPath) as! FormTextFieldTableViewCell

      switch cellType {
      case .taxRate:
        cell.keyboardType = .DecimalPad
        cell.configure("Tax Rate %", value: "\(viewModel.order.taxRate * 100)", changeEvent: .EditingDidEnd) { [weak self] newValue in
          if let value = Float(newValue ?? "") {
            self?.viewModel.order.taxRate = value / 100
          }
        }
      case .shippingRate:
        cell.keyboardType = .DecimalPad
        cell.configure("Shipping %", value: "\(viewModel.order.shippingRate * 100)", changeEvent: .EditingDidEnd) { [weak self] newValue in
          if let value = Float(newValue ?? "") {
            self?.viewModel.order.shippingRate = value / 100
          }
        }
      case .notes:
        cell.keyboardType = .Default
        cell.configure("Notes", value: viewModel.order.notes, changeEvent: .EditingDidEnd) { [weak self] newValue in
          self?.viewModel.order.notes = newValue ?? ""
        }
      }

      return cell

    case .summary:
      let cell = tableView.dequeueReusableCellWithIdentifier("orderSummaryCell", forIndexPath: indexPath) as! OrderSummaryTableViewCell
      cell.configure(viewModel)
      return cell
    }
  }

  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    guard let section = Section(rawValue: indexPath.section) else { return 44 }

    switch section {
    case .lineItems, .settings: return 44
    case .summary: return UITableViewAutomaticDimension
    }
  }
}
