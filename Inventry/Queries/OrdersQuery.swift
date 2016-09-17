import RxSwift

struct OrdersQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Order]> {
    return user.flatMapLatest { user -> Observable<[Order]> in
      return Database.find(ids: user.orders)
    }.map(sortByCreated)
  }
}

