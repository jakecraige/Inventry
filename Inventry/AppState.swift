import RxSwift
import Firebase

struct AppState {
  /// The "current order". This is used to store the order as a user progresses through a checkout flow
  let order = Variable(Order.new())

  /// All products. Used as an in memory reference
  let allProducts = Variable([Product]())

  /// All orders. Used as an in memory reference
  let allOrders = Variable([Order]())

  /// Currently signed in user
  let user = Variable(FIRAuth.auth()?.currentUser)
}
