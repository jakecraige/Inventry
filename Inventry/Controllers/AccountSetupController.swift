import UIKit
import RxSwift
import RxCocoa
import Firebase

class AccountSetupController: UIViewController {
  let disposeBag = DisposeBag()

  @IBOutlet var signUpButton: UIButton!
  @IBOutlet var connectStripeButton: UIButton!
  @IBOutlet var getStartedButton: UIButton!

  override func viewDidLoad() {
    let signedIn = store.signedIn
    let stripeAuthed = store.user
      .map { $0.accountSetupComplete }
      .asDriver(onErrorJustReturn: false)
      .startWith(false)

    let signInEnabled = signedIn.map(not)
    let connectStripeEnabled = Driver.combineLatest(signedIn, stripeAuthed.map(not), resultSelector: and)
    let getStartedEnabled = Driver.combineLatest(signedIn, stripeAuthed, resultSelector: and)

    signInEnabled.drive(signUpButton.rx_enabled).addDisposableTo(disposeBag)
    connectStripeEnabled.drive(connectStripeButton.rx_enabled).addDisposableTo(disposeBag)
    getStartedEnabled.drive(getStartedButton.rx_enabled).addDisposableTo(disposeBag)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "connectStripeSegue":
      let vc = segue.destinationViewController as! StripeAuthenticationController
      vc.connectAccount.subscribe(
        onNext: handleConnectedAccount,
        onError: handleStripeError
      ).addDisposableTo(disposeBag)
    default: break
    }
  }

  @IBAction func signUpTapped(sender: UIButton) {
    AuthenticationController().present(onViewController: self)
  }

  @IBAction func resetAccountTapped(sender: UIButton) {
    _ = try? FIRAuth.auth()?.signOut()
    fatalError("Force a restart")
  }

  private func handleConnectedAccount(account: StripeConnectAccount) {
    store.firUser.take(1).flatMap { user in
      store.dispatch(CreateUser(firUser: user, connectAccount: account))
    }.subscribe().addDisposableTo(disposeBag)
  }

  private func handleStripeError(error: ErrorType) {
    print(error)
  }
}
