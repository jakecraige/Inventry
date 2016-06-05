import UIKit
import Async
import Firebase
import RxSwift

class InitializeApplicationViewController: UIViewController {
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    if store.isSignedIn {
      store.user.take(1).subscribeNext { user in
        user.accountSetupComplete ? self.startMain() : self.startOnboarding()
      }.addDisposableTo(disposeBag)
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
