import RxSwift

struct ProductsQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Product]> {
    return user.flatMapLatest { user in
      return Database.observe(refs: user.products.map(Product.getChildRef))
    }.map { products in
      return products.sort { $0.name < $1.name }
    }
  }
}
