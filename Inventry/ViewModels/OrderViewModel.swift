import Foundation

struct OrderViewModel {
  let order: Order
  let products: [Product]
  let lineItems: [LineItemViewModel]

  var subtotal: Cents {
    return lineItems.reduce(0, combine: { $0 + $1.price })
  }

  var tax: Cents {
    return Int(Float(subtotal) * order.taxRate)
  }

  var total: Cents {
    return subtotal + tax
  }

  var customer: Customer? { return order.customer }

  init(order: Order, products: [Product]) {
    self.order = order
    self.products = products
    self.lineItems = order.lineItems.flatMap { item in
      guard let product = products.find({$0.id == item.productId}) else { return .None }

      return LineItemViewModel(lineItem: item, product: product)
    }
  }

  func lineItem(forIndexPath indexPath: NSIndexPath) -> LineItemViewModel {
    return lineItems[indexPath.row]
  }
}
