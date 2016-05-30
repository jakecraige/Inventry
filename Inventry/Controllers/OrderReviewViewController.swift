import UIKit
import PromiseKit

struct CancelledAlertError: ErrorType {}

private enum Section: Int {
  case lineItems
  case settings
  case summary
}
private let sectionCount = 3

private enum SettingsCell: Int {
  case taxRate
  case notes
}

class OrderReviewViewController: UITableViewController {
  @IBOutlet var placeOrderButton: UIBarButtonItem!

  var order: Order! {
    didSet { updateViewModel() }
  }
  var products: [Product] = [] {
    didSet {
      placeOrderButton.enabled = products.count > 0
      updateViewModel()
    }
  }
  var viewModel: OrderViewModel? {
    didSet {
      guard let oldOrder = oldValue?.order,
            let newOrder = viewModel?.order else { return tableView.reloadData() }

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
    Database.observeArrayOnce(eventType: .Value) { [weak self] in self?.products = $0 }
    tableView.registerNib(
      UINib(nibName: "FormTextFieldTableViewCell", bundle: nil),
      forCellReuseIdentifier: "formTextFieldCell"
    )
  }

  @IBAction func placeOrderTapped(sender: UIBarButtonItem) {
    confirmOkayToChargeCard().then(placeOrder).error { error in
      if error is CancelledAlertError {
        // ignore
      } else {
        print(error)
      }
    }
  }

  private func confirmOkayToChargeCard() -> Promise<Void> {
    guard let viewModel = viewModel else { fatalError() }
    return Promise { resolve, reject in
      let amount = PriceFormatter(viewModel.total).formatted
      let avc = UIAlertController(
        title: "Confirm Purchase",
        message: "This will charge the credit card \(amount), is that okay?",
        preferredStyle: .Alert
      )
      avc.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { _ in reject(CancelledAlertError()) }))
      avc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in resolve() }))
      
      self.presentViewController(avc, animated: true, completion: nil)
    }
  }

  private func placeOrder() {
    guard let viewModel = viewModel else { return }
    let processor = OrderProcessor(vm: viewModel)

    processor.process().then { order -> Void in
      print("Order completed: \(order)")
      self.dismissViewControllerAnimated(true, completion: nil)
    }.error { error in
      print("Error encountered: \(error)")
      self.handleProcessError(error)
    }
  }

  private func handleProcessError(error: ErrorType) {
    let avc = UIAlertController(
      title: "Uh oh!",
      message: "We're having trouble placing the order right now. Please try again later.",
      preferredStyle: .Alert
    )
    avc.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in }))
    self.presentViewController(avc, animated: true, completion: nil)
  }

  private func updateViewModel() {
    viewModel = OrderViewModel(
      order: order,
      products: products
    )
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
    case .lineItems: return viewModel?.lineItems.count ?? 0
    case .settings: return 2
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
      guard let viewModel = viewModel else { fatalError("We should never reach this when there's no viewModel") }
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
        cell.configure("Tax Rate %", value: "\(order.taxRate * 100)") { [weak self] newValue in
          if let value = Float(newValue ?? "") {
            self?.order.taxRate = value / 100
          }
        }
      case .notes:
        cell.keyboardType = .Default
        cell.configure("Notes", value: order.notes) { [weak self] newValue in
          self?.order.notes = newValue ?? ""
        }
      }

      return cell

    case .summary:
      let cell = tableView.dequeueReusableCellWithIdentifier("orderSummaryCell", forIndexPath: indexPath) as! OrderSummaryTableViewCell
      if let viewModel = viewModel {
        cell.configure(viewModel)
      }
      return cell
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    guard let section = Section(rawValue: indexPath.section) else { return 44 }

    switch section {
    case .lineItems, .settings: return 44
    case .summary: return 71
    }


  }
}
