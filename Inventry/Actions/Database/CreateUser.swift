import Delta
import Firebase
import RxSwift

struct CreateUser: DynamicActionType {
  let firUser: FIRUser
  let stripeAccessToken: String

  func call() -> Observable<String> {
    let user = User(id: firUser.uid)

    return Database.exists(user).flatMap { exists -> Observable<User> in
      if exists {
        return Database.observeObjectOnce(ref: user.childRef)
      } else {
        return Observable.just(user)
      }
    }.map { user in
      return with(user) { $0.stripeAccessToken = self.stripeAccessToken }
    }.map { user in
      return Database.save(user)
    }
  }
}
