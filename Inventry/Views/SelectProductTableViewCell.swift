import UIKit

class SelectProductTableViewCell: UITableViewCell {
  var order: Order!
  var product: Product!
  var moreProductAvailable = true {
    didSet {
      if moreProductAvailable {
        textLabel?.textColor = .blackColor()
        detailTextLabel?.textColor = .blackColor()
      } else {
        textLabel?.textColor = .grayColor()
        detailTextLabel?.textColor = .grayColor()
      }
    }
  }

  func configure(forOrder order: Order, product: Product) {
    self.order = order
    self.product = product
    updateUI()
  }

  func updateUI() {
    textLabel?.text = product.name
    detailTextLabel?.text = .None

    if let item = order.item(forProduct: product) {
      check(item)
    } else {
      uncheck()
    }
  }

  private func check(item: LineItem) {
    moreProductAvailable = product.quantity > item.quantity
    accessoryType = .Checkmark
    detailTextLabel?.text = "In Order: \(item.quantity) — Left In Stock: \(product.quantity - item.quantity)"
  }

  private func uncheck() {
    moreProductAvailable = product.quantity > 0
    accessoryType = .None
  }
}
