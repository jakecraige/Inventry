import RxSwift

struct ProductQuery: Query {
  let id: String

  func build() -> Observable<Product> {
    return Database.observe(query: Product.getChildRef(id))
  }
}
