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
    FIRAuth.auth()?.addAuthStateDidChangeListener { _, user in
      store.dispatch(UpdateAuth(user: user))
    }

    store.user.distinctUntilChanged().flatMap { user in
      store.dispatch(CreateUser(firUser: user))
    }.subscribe().addDisposableTo(disposeBag)
  }

  private func observeProducts() {
    store.user.distinctUntilChanged().flatMap { user in
      return Database<Product>.allWhere(key: "user_id", value: user.uid)
    }.subscribeNext { products in
      let sortedByName = products.sort { lhs, rhs in lhs.name < rhs.name }
      store.dispatch(SetAllProducts(products: sortedByName))
    }.addDisposableTo(disposeBag)
  }

  private func observeOrders() {
    store.user.distinctUntilChanged().flatMap { user in
      return Database<Order>.allWhere(key: "user_id", value: user.uid)
    }.subscribeNext { orders in
      let sortedByCreated = orders.sort { lhs, rhs in
        guard let lCreated = lhs.timestamps?.createdAt, rCreated = rhs.timestamps?.createdAt
          else { return true }
        return lCreated.compare(rCreated) == .OrderedAscending
      }
      print(orders)
      store.dispatch(SetAllOrders(orders: sortedByCreated))
    }.addDisposableTo(disposeBag)
  }
}
