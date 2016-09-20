import Delta
import Firebase
import RxSwift

struct CreateUser: DynamicActionType {
  let firUser: FIRUser
  let connectAccount: StripeConnectAccount

  func call() -> Observable<String> {
    return initializeUsers().map { user, publicUser in
      Database.save(
          Database.valuesForUpdate(user, includeRootKey: true) +
          Database.valuesForUpdate(publicUser, includeRootKey: true)
      )
      return user.uid
    }
  }

  func initializeUsers() -> Observable<(User, PublicUser)> {
    return Observable.combineLatest(initializeUser(), initializePublicUser()) { user, publicUser in
      return (user, publicUser)
    }
  }

  func initializeUser() -> Observable<User> {
    let user = User(id: firUser.uid)

    return Database.exists(user.childRef).flatMap { exists -> Observable<User> in
      if exists {
        return UserQuery(id: user.uid).build().take(1)
      } else {
        return Observable.just(user)
      }
    }.map { user -> User in
      if self.connectAccount.isNull {
        return user
      } else {
        var newUser = user
        newUser.stripeConnectAccount = self.connectAccount
        return newUser
      }
    }
  }

  func initializePublicUser() -> Observable<PublicUser> {
    let user = PublicUser(id: firUser.uid, name: firUser.displayName ?? "Unknown Name")
    return Database.exists(user.childRef).flatMap { exists -> Observable<PublicUser> in
      if exists {
        return PublicUserQuery(id: user.id!).build().take(1)
      } else {
        return Observable.just(user)
      }
    }
  }
}
