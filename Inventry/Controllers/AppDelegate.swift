import UIKit
import Firebase
import Stripe
import FirebaseAuthUI
import HockeySDK
import RxSwift

let applicationViewController = ApplicationViewController()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var firebaseSyncController: FirebaseSyncController?
  let disposeBag = DisposeBag()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    configureFirebase()
    configureHockey()
    Stripe.setDefaultPublishableKey(Environment.stripeApiKey)
    firebaseSyncController = FirebaseSyncController()
    firebaseSyncController?.sync()

    window = UIWindow(frame: UIScreen.main.bounds)
    if let window = window {
      window.rootViewController = applicationViewController
      window.makeKeyAndVisible()
    }

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    guard let authUI = FIRAuthUI.default() else { return false }

    return authUI.handleOpen(url, sourceApplication: options[.sourceApplication] as! String?)
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

  func configureHockey() {
    guard Environment.current != .development  else { return }
    let manager = BITHockeyManager.shared()
    manager.configure(withIdentifier: Environment.hockeyAppIdentifier)
    manager.isCrashManagerDisabled = true
    manager.start()
    manager.authenticator.authenticateInstallation()
  }
}
