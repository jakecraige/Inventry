import RxSwift
import RxCocoa
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

  var isSignedIn: Bool {
    return state.value.firUser.value != .None
  }

  var signedIn: Driver<Bool> {
    return state.value.firUser.asObservable().map { user in
      return user != .None
    }.asDriver(onErrorJustReturn: false)
  }

  var firUser: Observable<FIRUser> {
    return state.value.firUser.asObservable()
      .filter { $0 != .None }
      .map { $0! }
  }

  var user: Observable<User> {
    return state.value.user.asObservable()
      .filter { $0 != .None }
      .map { $0! }
  }
}
