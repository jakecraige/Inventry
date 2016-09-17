import Firebase
import RxSwift

/// This class is used to hydrate the Delta store with data from Firebase
/// and update it if necessary so we're using it rather than Firebase's API
/// across the app. It should live as a singleton on the AppDelegate, so we
/// don't need to worry about deallocating listeners.
class FirebaseSyncController {
  let disposeBag = DisposeBag()

  func sync() {
    observeAuthState()
    observeProducts()
    observeOrders()
  }

  private func observeAuthState() {
    FIRAuth.auth()?.addAuthStateDidChangeListener { _, firUser in
      store.dispatch(UpdateAuth(firUser: firUser))
    }

    store.firUser
      .flatMapLatest { UserQuery(id: $0.uid).build() }
      .retry()
      .subscribeNext { user in
        store.dispatch(UpdateAuth(user: user))
      }.addDisposableTo(disposeBag)
  }

  private func observeProducts() {
    ProductsQuery(user: store.user).build()
      .subscribeNext { products in
        store.dispatch(SetAllProducts(products: products))
      }.addDisposableTo(disposeBag)
  }

  private func observeOrders() {
    OrdersQuery(user: store.user).build()
      .subscribeNext { orders in
        store.dispatch(SetAllOrders(orders: orders))
      }.addDisposableTo(disposeBag)
  }
}
