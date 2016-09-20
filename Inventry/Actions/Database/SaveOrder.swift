import Delta
import RxSwift

struct SaveOrder: DynamicActionType {
  let order: Order

  func call() -> Observable<Order> {
    return store.user.take(1).map { (user: User) -> Order in
      var newOrder = self.order
      newOrder.userId = user.uid
      let id = Database.save(newOrder)

      var newUser = user
      newUser.orders.append(id)
      _ = Database.save(newUser)

      return newOrder
    }
  }
}
