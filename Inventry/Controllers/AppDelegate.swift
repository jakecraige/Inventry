import UIKit
import Firebase
import Stripe
import FirebaseAuthUI
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    configureFirebase()
    configureHockey()
    Stripe.setDefaultPublishableKey(Environment.stripeApiKey)
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
    if Environment.current == .Development {
      config.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
    }
    config.setDefaultsFromPlistFileName("RemoteConfigDefaults")
    config.fetchWithCompletionHandler { _ in
      config.activateFetched()
      print("Latest remote config activated")
    }
  }

  func configureHockey() {
    guard Environment.isDevelopment else { return }

    let manager = BITHockeyManager.sharedHockeyManager()
    manager.configureWithIdentifier(Environment.hockeyAppIdentifier)
    manager.startManager()
    manager.authenticator.authenticateInstallation()
    manager.crashManager.crashManagerStatus = .AutoSend
  }
}
