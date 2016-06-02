import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

struct AuthenticationController {
  func present(onViewController viewController: UIViewController) {
    guard !store.signedIn else { return }
    guard let authUI = FIRAuthUI.authUI(),
          let clientID = FIRApp.defaultApp()?.options.clientID,
          let googleUI = FIRGoogleAuthUI(clientID: clientID)
    else { return }

    authUI.signInProviders = [googleUI]
    authUI.signInWithEmailHidden = false

    viewController.presentViewController(
      authUI.authViewController(),
      animated: true,
      completion: nil
    )
  }
}
