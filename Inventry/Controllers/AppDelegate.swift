import UIKit
import Firebase
import Stripe
import FirebaseAuthUI
import HockeySDK
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var firebaseSyncController: FirebaseSyncController?
  let disposeBag = DisposeBag()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    configureFirebase()
    configureHockey()
    monitorAuthState()
    Stripe.setDefaultPublishableKey(Environment.stripeApiKey)
    firebaseSyncController = FirebaseSyncController()
    firebaseSyncController?.sync()
    return true
  }

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    guard let authUI = FIRAuthUI.authUI(),
          let sourceApp = sourceApplication else { return false }

    return authUI.handleOpenURL(url, sourceApplication: sourceApp)
  }

  func configureFirebase() {
    FIRApp.configure()
    let config = FIRRemoteConfig.remoteConfig()
    let expirationDuration: Double
    if Environment.current == .Development {
      config.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
      expirationDuration = 0
    } else {
      expirationDuration = 3600 // 1hr
    }
    config.setDefaultsFromPlistFileName("RemoteConfigDefaults")
    config.fetchWithExpirationDuration(expirationDuration) { _ in
      config.activateFetched()
      print("Latest remote config activated")
    }
  }

  func configureHockey() {
    let manager = BITHockeyManager.sharedHockeyManager()
    manager.configureWithIdentifier(Environment.hockeyAppIdentifier)
    manager.startManager()
    manager.authenticator.authenticateInstallation()
    manager.crashManager.crashManagerStatus = .AutoSend
  }

  func monitorAuthState() {
    // Skip first one that comes through when starting the app
    let signedOut = store.signedIn.distinctUntilChanged().skip(1).filter(not)
    signedOut.driveNext { _ in
      let vc = UIStoryboard.instantiateInitialViewController(forStoryboard: .Onboarding)
      self.window?.rootViewController = vc
      self.window?.makeKeyAndVisible()
    }.addDisposableTo(disposeBag)
  }
}
