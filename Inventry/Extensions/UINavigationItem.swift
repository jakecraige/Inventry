import UIKit

private var rightButtonHolder: UIBarButtonItem?
private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
private let loadingButton = UIBarButtonItem(customView: loadingIndicator)

extension UINavigationItem {
  func startLoadingRightButton() {
    rightButtonHolder = rightBarButtonItem
    rightBarButtonItem = loadingButton
    loadingIndicator.startAnimating()
  }

  func stopLoadingRightButton() {
    rightBarButtonItem = rightButtonHolder
    loadingIndicator.stopAnimating()
  }
}
