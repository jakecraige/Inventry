import UIKit
import RxSwift

private class InitializingAppViewController: UIViewController {
  override func viewDidLoad() {
    title = "Inventry"
  }
}

final class ApplicationViewController: UIViewController, ViewControllerContainer {
  let disposeBag = DisposeBag()
  let controller = ApplicationController()
  
  var activeViewController = UIViewController() {
    willSet {
      // If the currently active VC has presented VCs and we try to set a new one, it won't be
      // visible. This dismiss makes sure anything it's dismissed is released before we set
      // the next one. It performs a noop if there's nothing presented.
      activeViewController.dismiss(animated: true, completion: .none)
      remove(vc: activeViewController)
    }
    didSet {
      let animation = CATransition()
      animation.duration = 0.3
      animation.type = kCATransitionFade
      view.layer.add(animation, forKey: .none)
      show(vc: activeViewController)
      setNeedsStatusBarAppearanceUpdate()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    activeViewController = UINavigationController(
      rootViewController: InitializingAppViewController()
    )

    controller.initialSetup(application: UIApplication.shared)

    if store.isSignedIn {
      transitionToMain()
    } else {
      transitionToOnboarding()
    }
  }

  override var prefersStatusBarHidden: Bool {
    return activeViewController.prefersStatusBarHidden
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return activeViewController.preferredStatusBarStyle
  }
}

private extension ApplicationViewController {
  func startMonitoringAuthState() {
    let signedOut = store.signedIn.filter(not).distinctUntilChanged()
    signedOut
      .drive(onNext: { [weak self] _ in
        self?.transitionToOnboarding()
      })
      .addDisposableTo(disposeBag)
  }

  func transitionToMain() {
    let vc = UIStoryboard.initialViewController(storyboard: .Main)
    controller.user()
      .subscribe(onNext: { [weak self] user in
        guard let `self` = self else { return }
        store.dispatch(UpdateAuthUser(user: user))

        if user.accountSetupComplete {
          self.startMonitoringAuthState()
          self.activeViewController = vc
        } else {
          self.transitionToOnboarding()
        }
      })
      .addDisposableTo(disposeBag)
  }

  func transitionToOnboarding() {
    let navVC: UINavigationController = UIStoryboard.initialViewController(storyboard: .Onboarding)
    let vc = navVC.viewControllers.first as! AccountSetupController
    vc.userSignedIn
      .subscribe(onNext: { [weak self] user in
        store.dispatch(UpdateAuthUser(user: user))
        self?.transitionToMain()
      })
      .addDisposableTo(disposeBag)
    activeViewController = navVC
  }
}
