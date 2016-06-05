import UIKit
import Async
import Firebase
import RxSwift

class InitializeApplicationViewController: UIViewController {
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    if store.isSignedIn {
      store.firUser
        .timeout(3, scheduler: MainScheduler.instance)
        .flatMap { user in
          // Verify user exists to prevent decoding errors breaking stuff
          return store.dispatch(CreateUser(firUser: user, connectAccount: StripeConnectAccount.null()))
        }.flatMap { userID in
          return Database<User>.observeObjectOnce(ref: User.getChildRef(userID))
        }.take(1)
        .map { $0.accountSetupComplete }
        .subscribe(
          onNext: { accountSetupComplete in
            accountSetupComplete ? self.startMain() : self.startOnboarding()
          },
          onError: { error in
            print(error)
            _ = try? FIRAuth.auth()?.signOut()
            self.startOnboarding()
          }
        ).addDisposableTo(disposeBag)
    } else {
      startOnboarding()
    }
  }

  private func startOnboarding() {
    Async.main { self.performSegueWithIdentifier("onboardingSegue", sender: self) }
  }

  private func startMain() {
    Async.main { self.performSegueWithIdentifier("mainSegue", sender: self) }
  }
}
