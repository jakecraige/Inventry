import Delta
import Firebase
import RxSwift

struct SaveOrder: DynamicActionType {
  let order: Order

  func call() -> Observable<Order> {
    return store.user.take(1).map { user in
      let order = with(self.order) { $0.userId = user.uid }
      let id = Database.save(order)

      let user = with(user) { $0.orders.append(id) }
      Database.save(user)
      return order
    }
  }
}
