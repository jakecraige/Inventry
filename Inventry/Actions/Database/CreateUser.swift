import Delta
import Firebase
import RxSwift

struct CreateUser: DynamicActionType {
  let firUser: FIRUser
  let connectAccount: StripeConnectAccount

  func call() -> Observable<String> {
    let user = User(id: firUser.uid, name: firUser.displayName ?? "")

    return Database.exists(user).flatMap { exists -> Observable<User> in
      if exists {
        return Database.observeObject(ref: user.childRef).take(1)
      } else {
        return Observable.just(user)
      }
    }.map { user -> User in
      if self.connectAccount.isNull {
        return user
      } else {
        return with(user) { $0.stripeConnectAccount = self.connectAccount }
      }
    }.map { user in
      return Database.save(user)
    }
  }
}
