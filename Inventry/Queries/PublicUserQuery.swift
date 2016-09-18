import RxSwift

struct PublicUserQuery: Query {
  let id: String

  func build() -> Observable<PublicUser> {
    return Database.observe(ref: PublicUser.getChildRef(id))
  }
}
