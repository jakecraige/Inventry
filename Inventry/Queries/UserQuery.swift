import RxSwift

struct UserQuery: Query {
  let id: String

  func build() -> Observable<User> {
    return Database.observeObject(ref: User.getChildRef(id))
  }
}
