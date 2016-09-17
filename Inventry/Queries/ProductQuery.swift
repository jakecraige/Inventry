import RxSwift

struct ProductQuery: Query {
  let id: String

  func build() -> Observable<Product> {
    return Database.observeObject(ref: Product.getChildRef(id))
  }
}
