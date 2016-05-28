import Foundation
import PromiseKit
import Swish

struct TokenMissingError: ErrorType { }

struct OrderProcessor {
  let order: Order
  let products: [Product]

  func process() -> Promise<Order> {
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
      return self.updateAndPersistOrder(id, charge: charge)
    } // then reduce product quantities
  }

  private func updateAndPersistOrder(id: String, charge: Charge) -> Order {
    let updatedOrder = Order(
      id: id,
      lineItems: self.order.lineItems,
      paymentToken: self.order.paymentToken,
      charge: charge,
      customer: self.order.customer
    )
    Database.save(updatedOrder)
    return updatedOrder
  }
}
