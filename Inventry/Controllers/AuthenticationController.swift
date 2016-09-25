import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

struct AuthenticationController {
  func present(onViewController viewController: UIViewController) {
    viewController.present(
      firebaseAuthViewController(),
      animated: true,
      completion: nil
    )
  }

  private func firebaseAuthViewController() -> UIViewController {
    guard let authUI = FIRAuthUI.default(),
          let clientID = FIRApp.defaultApp()?.options.clientID
      else { fatalError("Couldn't initialize Firebase UI") }

    let googleUI = FIRGoogleAuthUI(clientID: clientID)
    authUI.providers = [googleUI]
    authUI.isSignInWithEmailHidden = false

    return authUI.authViewController()
  }
}
