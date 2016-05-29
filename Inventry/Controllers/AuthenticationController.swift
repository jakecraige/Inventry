import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

struct AuthenticationController {
  var signedIn: Bool {
    guard let auth = FIRAuth.auth() else { return false }
    return auth.currentUser != .None
  }

  func present(onViewController viewController: UIViewController) {
    guard !signedIn else { return }
    guard let authUI = FIRAuthUI.authUI(),
          let clientID = FIRApp.defaultApp()?.options.clientID,
          let googleUI = FIRGoogleAuthUI(clientID: clientID)
    else { return }

    authUI.signInProviders = [googleUI]
    authUI.signInWithEmailHidden = true

    viewController.presentViewController(
      authUI.authViewController(),
      animated: true,
      completion: nil
    )
  }
}
