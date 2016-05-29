import Foundation

struct LineItemViewModel {
  let lineItem: LineItem
  let product: Product
}

struct OrderReviewViewModel {
  let order: Order
  let products: [Product]
  let lineItems: [LineItemViewModel]

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
