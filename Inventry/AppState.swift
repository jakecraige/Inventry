import RxSwift

struct AppState {
  /// The "current order". This is used to store the order as a user progresses through a checkout flow
  let order = Variable(Order.new())

  /// All products. Used as an in memory reference
  let allProducts = Variable([Product]())
}

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
}
