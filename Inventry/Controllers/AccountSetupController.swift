import UIKit
import RxSwift
import RxCocoa
import Firebase

class AccountSetupController: UIViewController {
  let disposeBag = DisposeBag()

  @IBOutlet var signUpButton: UIButton!
  @IBOutlet var connectStripeButton: UIButton!
  @IBOutlet var getStartedButton: UIButton!
  let userSignedIn = PublishSubject<User>()

  override func viewDidLoad() {
    let signedIn = store.signedIn
    let user = store.firUser.flatMapLatest { UserQuery(id: $0.uid).build() }.retry().shareReplay(1)
    let stripeAuthed = user
      .map { $0.accountSetupComplete }
      .asDriver(onErrorJustReturn: false)
      .startWith(false)

    let signInEnabled = signedIn.map(not)
    let connectStripeEnabled = Driver.combineLatest(signedIn, stripeAuthed.map(not), resultSelector: and)
    let getStartedEnabled = Driver.combineLatest(signedIn, stripeAuthed, resultSelector: and)

    signInEnabled.drive(signUpButton.rx.enabled).addDisposableTo(disposeBag)
    connectStripeEnabled.drive(connectStripeButton.rx.enabled).addDisposableTo(disposeBag)
    getStartedEnabled.drive(getStartedButton.rx.enabled).addDisposableTo(disposeBag)
    
    getStartedButton.rx.controlEvent(.touchUpInside)
      .flatMapLatest { return user }
      .bindTo(userSignedIn)
      .addDisposableTo(disposeBag)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "connectStripeSegue":
      let vc = segue.destination as! StripeAuthenticationController
      vc.connectAccount.subscribe(
        onNext: handleConnectedAccount,
        onError: handleStripeError
      ).addDisposableTo(disposeBag)
    default: break
    }
  }

  @IBAction func signUpTapped(_ sender: UIButton) {
    AuthenticationController().present(onViewController: self)
  }

  fileprivate func handleConnectedAccount(_ account: StripeConnectAccount) {
    store.firUser.take(1).flatMap { user in
      store.dispatch(CreateUser(firUser: user, connectAccount: account))
    }.subscribe().addDisposableTo(disposeBag)
  }

  fileprivate func handleStripeError(_ error: Error) {
    print(error)
  }
}
