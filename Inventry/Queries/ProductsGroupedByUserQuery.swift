import RxSwift
import Firebase

struct ProductsGroupedByUserQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[PublicUser: [Product]]> {
    return Observable.combineLatest(
      PublicUsersQuery().build(),
      ProductsQuery(user: user).build()
    ) { users, products -> [PublicUser: [Product]] in
      return self.groupByUser(products: products, users: users)
    }
  }

  func groupByUser(products: [Product], users: [PublicUser]) -> [PublicUser: [Product]] {
    return products.reduce([:]) { acc, product in
      guard let user = users.find({ ($0.id ?? "") == product.userId }) else { return acc }
      let newValue = (acc[user] ?? []) + [product]
      return acc + [user: newValue]
    }
  }
}
