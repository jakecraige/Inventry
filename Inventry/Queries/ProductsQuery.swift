import RxSwift

struct ProductsQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Product]> {
    return user.flatMapLatest { user -> Observable<[Product]> in
      return Database.observe(queries: user.products.map(Product.getChildRef))
    }.map { products in
      return products.sort { $0.name < $1.name }
    }
  }
}
