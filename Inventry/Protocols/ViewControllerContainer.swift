protocol ViewControllerContainer {
  var containerView: UIView { get }
}

extension ViewControllerContainer where Self: UIViewController {
  var containerView: UIView {
    return view
  }

  func remove(vc: UIViewController) {
    vc.willMove(toParentViewController: .none)
    vc.view.removeFromSuperview()
    vc.removeFromParentViewController()
  }

  func show(vc: UIViewController) {
    addChildViewController(vc)
    vc.view.frame = containerView.bounds
    containerView.addSubview(vc.view)
    vc.didMove(toParentViewController: self)
  }
}
