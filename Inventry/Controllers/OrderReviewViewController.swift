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
  var viewModel = OrderViewModel(order: Order.new(), products: []) {
    didSet {
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
    navigationItem.startLoadingRightButton()
    confirmOkayToChargeCard()
      .then(placeOrder)
      .then { [weak self] in self?.dismissViewControllerAnimated(true, completion: nil) }
      .always { [weak self] in self?.navigationItem.stopLoadingRightButton() }
      .error { error in
      if error is CancelledAlertError {
        // ignore
      } else {
        print(error)
        self.handleProcessError(error)
      }
    }
  }

  private func confirmOkayToChargeCard() -> Promise<Void> {
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

  private func placeOrder() -> Promise<Void> {
    let processor = OrderProcessor(vm: viewModel)

    return processor.process().then { order -> Void in
      print("Order completed: \(order)")
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
    case .lineItems: return viewModel.lineItems.count
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
        cell.configure("Tax Rate %", value: "\(order.taxRate * 100)", changeEvent: .EditingDidEnd) { [weak self] newValue in
          if let value = Float(newValue ?? "") {
            self?.order.taxRate = value / 100
          }
        }
      case .notes:
        cell.keyboardType = .Default
        cell.configure("Notes", value: order.notes, changeEvent: .EditingDidEnd) { [weak self] newValue in
          self?.order.notes = newValue ?? ""
        }
      }

      return cell

    case .summary:
      let cell = tableView.dequeueReusableCellWithIdentifier("orderSummaryCell", forIndexPath: indexPath) as! OrderSummaryTableViewCell
      cell.configure(viewModel)
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
