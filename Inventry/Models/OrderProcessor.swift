import Foundation
import Swish
import RxSwift

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

  func process() -> Observable<Order> {
    guard let paymentToken = order.paymentToken else {
      return Observable.error(TokenMissingError())
    }
    // Save for an ID to use in the charge description
    let id = Database.save(order)

    // Charge credit card
    let request = ProcessPaymentRequest(
      amount: vm.total,
      description: "Order: \(id)",
      token: paymentToken
    )
    let processPayment: Observable<Charge> = APIClient().performRequest(request)

    return processPayment.flatMap { charge in
      return self.updateAndPersistOrder(id, charge: charge)
    }.map { order in
      self.reduceInventoryQuantities()
      return order
    }
  }

  private func updateAndPersistOrder(id: String, charge: Charge) -> Observable<Order> {
    let updatedOrder = Order(
      id: id,
      lineItems: order.lineItems,
      paymentToken: order.paymentToken,
      charge: charge,
      customer: order.customer,
      taxRate: order.taxRate,
      shippingRate: order.shippingRate,
      notes: order.notes,
      timestamps: order.timestamps,
      userId: order.userId
    )
    return store.dispatch(SaveOrder(order: updatedOrder))
  }

  private func reduceInventoryQuantities() {
    vm.lineItems.forEach { itemVM in
      let product = itemVM.product.decrement(by: itemVM.lineItem.quantity)
      Database.save(product)
    }
  }
}
