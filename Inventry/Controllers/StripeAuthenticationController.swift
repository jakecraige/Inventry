import UIKit
import WebKit
import RxSwift
import Argo

class StripeAuthenticationController: UIViewController {
  var webView: WKWebView!
  var connectAccount = PublishSubject<StripeConnectAccount>()

  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let clientID = Environment.stripeClientID
    let url = URL(string: "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=\(clientID)&scope=read_write")!
    let req = URLRequest(url: url)
    webView.load(req)
  }

  var onStripePage: Bool {
    guard let url = webView.url else { return false }

    return !url.absoluteString.contains("stripe")
  }

  @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
    dismiss()
  }

  func dismiss() {
    _ = navigationController?.popViewController(animated: true)
  }
}

extension StripeAuthenticationController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    guard !onStripePage else { return }

    webView.evaluateJavaScript("document.body.innerText") { body, error in
      guard let text = body as? String,
                let data = text.data(using: String.Encoding.utf8),
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
      else { return }

      if let error = error {
        self.connectAccount.onError(error)
        self.connectAccount.onCompleted()
        return
      }

      switch decode(json) as Decoded<StripeConnectAccount> {
      case let .success(account):
        self.connectAccount.onNext(account)
      case let .failure(error):
        self.connectAccount.onError(error)
      }

      self.connectAccount.onCompleted()
      self.dismiss()
    }
  }
}
