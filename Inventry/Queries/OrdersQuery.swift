import RxSwift

struct OrdersQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Order]> {
    return user.flatMapLatest { user in
      return Database.observe(refs: user.orders.map(Order.getChildRef))
    }.map(sortByCreated)
  }
}
