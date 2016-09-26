import RxSwift
import Firebase

struct AppState {
  /// The "current order". This is used to store the order as a user progresses through a checkout flow
  let order = Variable(Order.new())

  /// Currently signed in firebase user
  let firUser = Variable(FIRAuth.auth()?.currentUser)

  /// Currently signed in user
  let user = Variable<User?>(.none)
}
