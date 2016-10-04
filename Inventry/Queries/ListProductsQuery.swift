import RxSwift
import Firebase

struct ListProductsQuery: Query {
  let list: List

  func build() -> Observable<[PopulatedListProduct]> {
    let productRefs = list.products.map { Product.getChildRef($0.product) }.map { $0 as FIRDatabaseQuery }
    let products: Observable<[Product]> = Database.observe(refs: productRefs)
    let listProducts = Observable.just(list.products)

    return Observable.zip(products, listProducts) { (lhs: [Product], rhs: [ListProduct]) -> [PopulatedListProduct] in
      return zip(lhs, rhs).map { product, listProduct in
        return PopulatedListProduct(product: product, quantity: listProduct.quantity)
      }
    }
  }
}
