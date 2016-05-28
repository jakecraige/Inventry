import UIKit
import Firebase
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    FIRApp.configure()
    Stripe.setDefaultPublishableKey("pk_test_9t5vFFqvMgBYGscK1XNwPdcj")
    return true
  }
}
