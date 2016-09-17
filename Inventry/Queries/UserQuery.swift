import RxSwift

struct UserQuery: Query {
  let id: String

  func build() -> Observable<User> {
    return Database.observe(ref: User.getChildRef(id))
  }
}
