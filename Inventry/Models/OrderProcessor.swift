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
    products = vm.products
    // it needs to have an ID set even though it's not persisted so we can add a note to the payment
    // with the orderID
    order = with(vm.order) { $0.id = $0.childRef.key }
  }

  func process() -> Observable<Order> {
    let (vm, order) = (self.vm, self.order)
    guard let paymentToken = order.paymentToken else {
      return Observable.error(TokenMissingError())
    }

    return store.user.flatMap { user -> Observable<Charge> in
      let request = ProcessPaymentRequest(
        amount: vm.total,
        description: "Order: \(order.id!)",
        token: paymentToken,
        accountID: user.stripeConnectAccount.stripeUserID
      )
      return APIClient().performRequest(request)
    }.flatMap { charge in
      return self.updateAndPersistOrder(withCharge: charge)
    }.map { order in
      self.reduceInventoryQuantities()
      return order
    }
  }

  private func updateAndPersistOrder(withCharge charge: Charge) -> Observable<Order> {
    let updatedOrder = with(order) { $0.charge = charge }
    return store.dispatch(SaveOrder(order: updatedOrder))
  }

  private func reduceInventoryQuantities() {
    vm.lineItems.forEach { itemVM in
      let product = itemVM.product.decrement(by: itemVM.lineItem.quantity)
      Database.save(product)
    }
  }
}
