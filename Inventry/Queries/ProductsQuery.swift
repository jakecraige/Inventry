import RxSwift
import Firebase

struct ProductsQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Product]> {
    return user.flatMapLatest { user in
      return self.getInventoryProducts(user)
    }.map { products in
      return products.sorted { $0.name < $1.name }
    }
  }

  func getInventoryProducts(_ user: User) -> Observable<[Product]> {
    return Database.observe(refs: user.products.map(Product.getChildRef))
  }
}
