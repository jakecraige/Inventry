import Foundation

struct OrderViewModel {
  static func null() -> OrderViewModel {
    return OrderViewModel(order: Order.new())
  }

  var order: Order
  let lineItems: [LineItemViewModel]

  var subtotal: Cents {
    return lineItems.reduce(0, { $0 + $1.price })
  }

  var tax: Cents {
    return Int(Float(subtotal) * order.taxRate)
  }

  var shipping: Cents {
    return Int(Float(subtotal) * order.shippingRate)
  }

  var total: Cents {
    return subtotal + tax + shipping
  }

  var customer: Customer? { return order.customer }

  init(order: Order) {
    self.order = order
    self.lineItems = order.lineItems.map(LineItemViewModel.init)
  }

  func lineItem(forIndexPath indexPath: IndexPath) -> LineItemViewModel {
    return lineItems[indexPath.row]
  }
}
