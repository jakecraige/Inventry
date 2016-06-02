import RxSwift

// MARK: Getters
extension Store {
  var order: Observable<Order> {
    return state.value.order.asObservable()
  }

  var allProducts: Observable<[Product]> {
    return state.value.allProducts.asObservable()
  }

  var orderViewModel: Observable<OrderViewModel> {
    return Observable.combineLatest(order, allProducts) { order, allProducts in
      return OrderViewModel(order: order, products: allProducts)
    }
  }

  var signedIn: Bool {
    return state.value.user.value != .None
  }
}
