import RxSwift
import Firebase

struct ListUsersQuery: Query {
  let list: List

  func build() -> Observable<[PublicUser]> {
    return Database.observe(refs: list.users.map { PublicUser.getChildRef($0) })
  }
}
