import UIKit
import RxSwift

final class ApplicationController {
  var application: UIApplication!

  func initialSetup(application: UIApplication) {
    self.application = application
  }

  func user() -> Observable<User> {
    return store.firUser
      .flatMap { user in user.getToken(forceRefresh: true).map { _ in user } }
      .flatMap { user in UserQuery(id: user.uid).build() }
  }
}
