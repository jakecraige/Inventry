import UIKit

class SelectProductTableViewCell: UITableViewCell {
  var order: Order!
  var product: Product!
  var moreProductAvailable = true {
    didSet {
      if moreProductAvailable {
        textLabel?.textColor = .black
        detailTextLabel?.textColor = .black
      } else {
        textLabel?.textColor = .gray
        detailTextLabel?.textColor = .gray
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
    detailTextLabel?.text = .none

    if let item = order.item(forProduct: product) {
      check(item)
    } else {
      uncheck()
    }
  }

  fileprivate func check(_ item: LineItem) {
    moreProductAvailable = product.quantity > item.quantity
    accessoryType = .checkmark
    detailTextLabel?.text = "In Order: \(item.quantity) — Left In Stock: \(product.quantity - item.quantity)"
  }

  fileprivate func uncheck() {
    moreProductAvailable = product.quantity > 0
    accessoryType = .none
  }
}
