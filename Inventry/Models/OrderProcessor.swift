import Foundation
import PromiseKit
import Swish

struct TokenMissingError: ErrorType { }

struct OrderProcessor {
  let vm: OrderViewModel
  let order: Order
  let products: [Product]

  init(vm: OrderViewModel) {
    self.vm = vm
    order = vm.order
    products = vm.products
  }

  func process() -> Promise<Order> {
    guard let paymentToken = order.paymentToken else {
      return Promise(error: TokenMissingError())
    }
    // Save for an ID to use in the charge description
    let id = Database.save(order)

    // Charge credit card
    let request = ProcessPaymentRequest(
      amount: vm.total,
      description: "Order: \(id)",
      token: paymentToken
    )
    let processPayment = APIClient().performRequest(request)

    return processPayment.then { charge -> Order in
      let updatedOrder = self.updateAndPersistOrder(id, charge: charge)
      self.reduceInventoryQuantities()
      return updatedOrder
    }
  }

  private func updateAndPersistOrder(id: String, charge: Charge) -> Order {
    let updatedOrder = Order(
      id: id,
      lineItems: order.lineItems,
      paymentToken: order.paymentToken,
      charge: charge,
      customer: order.customer,
      taxRate: order.taxRate,
      shippingRate: order.shippingRate,
      notes: order.notes,
      timestamps: order.timestamps
    )
    Database.save(updatedOrder)
    return updatedOrder
  }

  private func reduceInventoryQuantities() {
    vm.lineItems.forEach { itemVM in
      let product = itemVM.product.decrement(by: itemVM.lineItem.quantity)
      Database.save(product)
    }
  }
}
