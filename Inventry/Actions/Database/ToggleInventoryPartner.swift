import Delta
import Firebase
import RxSwift

struct ToggleInventoryPartner: DynamicActionType {
  let partner: PublicUser

  func call() -> Observable<User> {
    return store.user.take(1).map { user in
      // TODO: Perform a toggle...
      return user
    }
  }
}
