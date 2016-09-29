import UIKit
import RxSwift
import Firebase
import Stripe

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
