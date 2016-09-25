import Firebase
import RxSwift

/// This class is used to hydrate the Delta store with data from Firebase
/// and update it if necessary so we're using it rather than Firebase's API
/// across the app. It should live as a singleton on the AppDelegate, so we
/// don't need to worry about deallocating listeners.
class FirebaseSyncController {
  let disposeBag = DisposeBag()

  func sync() {
    observeProducts()
    observeOrders()
  }

  private func observeProducts() {
    ProductsQuery(user: store.user).build()
      .subscribe(onNext: { products in
        store.dispatch(SetAllProducts(products: products))
      }).addDisposableTo(disposeBag)
  }

  private func observeOrders() {
    OrdersQuery(user: store.user).build()
      .subscribe(onNext: { orders in
        store.dispatch(SetAllOrders(orders: orders))
      }).addDisposableTo(disposeBag)
  }
}
