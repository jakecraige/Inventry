import Foundation

struct OrderViewModel {
  static func null() -> OrderViewModel {
    return OrderViewModel(order: Order.new(), products: [])
  }

  var order: Order
  let products: [Product]
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

  init(order: Order, products: [Product]) {
    self.order = order
    self.products = products
    self.lineItems = order.lineItems.flatMap { item in
      guard let product = products.find({$0.id == item.productId}) else { return .none }

      return LineItemViewModel(lineItem: item, product: product)
    }
  }

  func lineItem(forIndexPath indexPath: IndexPath) -> LineItemViewModel {
    return lineItems[(indexPath as NSIndexPath).row]
  }
}
