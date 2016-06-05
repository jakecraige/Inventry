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
    let url = NSURL(string: "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=\(clientID)&scope=read_write")!
    let req = NSURLRequest(URL: url)
    webView.loadRequest(req)
  }

  var onStripePage: Bool {
    guard let url = webView.URL else { return false }

    return !url.absoluteString.containsString("stripe")
  }

  @IBAction func cancelTapped(sender: UIBarButtonItem) {
    dismiss()
  }

  func dismiss() {
    navigationController?.popViewControllerAnimated(true)
  }
}

extension StripeAuthenticationController: WKNavigationDelegate {
  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    guard !onStripePage else { return }

    webView.evaluateJavaScript("document.body.innerText") { body, error in
      guard let text = body as? String,
                data = text.dataUsingEncoding(NSUTF8StringEncoding),
                json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
      else { return }

      if let error = error {
        self.connectAccount.onError(error)
        self.connectAccount.onCompleted()
        return
      }

      switch decode(json) as Decoded<StripeConnectAccount> {
      case let .Success(account):
        self.connectAccount.onNext(account)
      case let .Failure(error):
        self.connectAccount.onError(error)
      }

      self.connectAccount.onCompleted()
      self.dismiss()
    }
  }
}
