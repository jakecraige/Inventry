import RxSwift
import Firebase

// MARK: Getters
extension Store {
  var order: Observable<Order> {
    return state.value.order.asObservable()
  }

  var allProducts: Observable<[Product]> {
    return state.value.allProducts.asObservable()
  }

  var allOrders: Observable<[Order]> {
    return state.value.allOrders.asObservable()
  }

  var orderViewModel: Observable<OrderViewModel> {
    return Observable.combineLatest(order, allProducts) { order, allProducts in
      return OrderViewModel(order: order, products: allProducts)
    }
  }

  var signedIn: Bool {
    return state.value.user.value != .None
  }

  var user: Observable<FIRUser> {
    return state.value.user.asObservable()
      .filter { $0 != .None }
      .map { $0! }
  }
}
