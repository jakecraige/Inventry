import RxSwift

struct ProductsQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Product]> {
    return user.flatMapLatest { user -> Observable<[Product]> in
      return Database.find(ids: user.products)
    }.map { products in
      return products.sort { $0.name < $1.name }
    }
  }
}
