import RxSwift

struct PublicUsersQuery: Query {
  func build() -> Observable<[PublicUser]> {
    return Database.observe(ref: PublicUser.ref)
  }
}
