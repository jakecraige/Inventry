import Delta
import Firebase
import RxSwift

struct SaveOrder: DynamicActionType {
  let order: Order

  func call() -> Observable<Order> {
    var order = self.order
    return store.user.map { user in
      order.userId = user.uid
      let id = Database.save(order)
      Database.save(User(id: user.uid, products: [], orders: [id]))
      return order
    }
  }
}
