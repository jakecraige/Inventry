import Firebase
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI

struct AuthenticationController {
  func present(onViewController viewController: UIViewController) {
    viewController.present(
      signInViewController(),
      animated: true,
      completion: nil
    )
  }

  // Temporary solution since FirebaseUI doesn't support Swift 3 yet.
  private func signInViewController() -> UIViewController {
    let vc = UIAlertController(title: "Sign in", message: "Please enter your email and password", preferredStyle: .alert)
    
    vc.addTextField { $0.placeholder = "email" }
    vc.addTextField { $0.placeholder = "password"; $0.isSecureTextEntry = true }
    vc.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { _ in
      let (email, password) = (vc.textFields?[0].text ?? "", vc.textFields?[1].text ?? "")
      FIRAuth.auth()?.signIn(withEmail: email, password: password) { _, error in
        if let error = error {
          print("Sign in error: \(error)")
        }
      }
    }))

    return vc
  }
  
}
