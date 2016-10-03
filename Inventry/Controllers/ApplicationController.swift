import UIKit
import RxSwift
import Firebase
import Stripe
import RealmSwift

var realm: Realm!

final class ApplicationController {
  var application: UIApplication!

  /// This is expected to be called before calling any other methods on this object.
  func initialSetup(application: UIApplication) {
    self.application = application
    configureServices()
    configureObservers()
  }

  func user() -> Observable<User> {
    return store.firUser
      .flatMap { user in user.getToken(forceRefresh: true).map { _ in user } }
      .flatMap { user in UserQuery(id: user.uid).build() }
  }
}

// MARK: Services
private extension ApplicationController {
  func configureServices() {
    configureFirebase()
    Stripe.setDefaultPublishableKey(Environment.stripeApiKey)
    configureRealm()
  }
  
  func configureFirebase() {
    FIRApp.configure()
    let config = FIRRemoteConfig.remoteConfig()
    let expirationDuration: Double
    if Environment.current == .development {
      config.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
      expirationDuration = 0
    } else {
      expirationDuration = 3600 // 1hr
    }
    config.setDefaultsFromPlistFileName("RemoteConfigDefaults")
    config.fetch(withExpirationDuration: expirationDuration) { _ in
      config.activateFetched()
      print("Latest remote config activated")
    }
  }

  func configureRealm() {
    let serverURL = URL(string: "http://localhost:9080")!
    let credential = Credential.usernamePassword(
      username: "devuser@example.com",
      password: "Password1",
      actions: [.useExistingAccount]
    )
    RealmSwift.User.authenticate(with: credential, server: serverURL) { user, error in
      if let user = user {
        let syncURL = URL(string: "realm://localhost:9080/~/public")!
        let config = Realm.Configuration(syncConfiguration: (user, syncURL))
        realm = try! Realm(configuration: config)
        print("Realm setup")
        self.seedRealm()
      } else if let error = error {
        print("Error", error)
      }
    }
  }
}

// MARK: Observers
private extension ApplicationController {
  func configureObservers() {
    observeFirebaseAuthState()
  }
  
  func observeFirebaseAuthState() {
    FIRAuth.auth()?.addStateDidChangeListener { _, firUser in
      store.dispatch(UpdateAuthFIRUser(firUser: firUser))
    }
  }
}

private extension ApplicationController {
  func seedRealm() {
    let user = RUser()
    user.name = "Jake Craige"
    let product = RProduct()
    product.name = "The Great Gatsby"
    product.quantity = 10
    product.user = user
    user.products.append(product)
    try! realm.write {
      realm.add([product, user])
    }
  }
}
