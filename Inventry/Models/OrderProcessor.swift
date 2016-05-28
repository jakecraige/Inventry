import Foundation
import PromiseKit
import Swish

struct TokenMissingError: ErrorType { }

struct OrderProcessor {
  let products: [Product]

  func process(order: Order) -> Promise<Order> {
    guard let paymentToken = order.paymentToken else {
      return Promise(error: TokenMissingError())
    }
    // Save for an ID to use in the charge description
    let id = Database.save(order)

    // Charge credit card
    let request = ProcessPaymentRequest(
      amount: order.calculateAmount(products),
      description: "Order: \(id)",
      token: paymentToken
    )
    let processPayment = APIClient().performRequest(request)

    return processPayment.then { charge in
      return self.updateAndPersistOrder(id, order: order, charge: charge)
    }.then { order in
      return self.reduceInventoryQuantities(order)
    }
  }

  private func updateAndPersistOrder(id: String, order: Order, charge: Charge) -> Order {
    let updatedOrder = Order(
      id: id,
      lineItems: order.lineItems,
      paymentToken: order.paymentToken,
      charge: charge,
      customer: order.customer
    )
    Database.save(updatedOrder)
    return updatedOrder
  }

  private func reduceInventoryQuantities(order: Order) -> Order {
    order.lineItems.forEach { item in
      if let product = products.find({($0.id ?? "") == item.productId}) {
        Database.save(product.decrement(by: item.quantity))
      }
    }
    return order
  }
}
