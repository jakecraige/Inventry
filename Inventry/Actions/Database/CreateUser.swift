import Delta
import Firebase
import RxSwift

struct CreateUser: DynamicActionType {
  let firUser: FIRUser

  func call() -> Observable<String> {
    let user = User(id: firUser.uid, products: [], orders: [])

    return Database.exists(user)
      .filter { exists in !exists }
      .map { _ in Database.save(user) }
  }
}
