import Firebase

/// This class is used to hydrate the Delta store with data from Firebase
/// and update it if necessary so we're using it rather than Firebase's API
/// across the app. It should live as a singleton on the AppDelegate, so we
/// don't need to worry about deallocating listeners.
class FirebaseSyncController {
  func sync() {
    observeAuthState()
    observeProducts()
  }

  private func observeAuthState() {
    FIRAuth.auth()?.addAuthStateDidChangeListener { _, user in
      store.dispatch(UpdateAuth(user: user))
    }
  }

  private func observeProducts() {
    Database.observeArray(eventType: .Value, orderBy: "name") {
      store.dispatch(SetAllProducts(products: $0))
    }
  }
}
