import UIKit
import Firebase
import Stripe
import FirebaseAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    FIRApp.configure()
    Stripe.setDefaultPublishableKey("pk_test_9t5vFFqvMgBYGscK1XNwPdcj")
    return true
  }

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    guard let authUI = FIRAuthUI.authUI(),
          let sourceApp = sourceApplication else { return false }

    return authUI.handleOpenURL(url, sourceApplication: sourceApp)
  }
}
