import Delta
import Firebase
import RxSwift

struct DeleteProduct: DynamicActionType {
  let product: Product

  func call() -> Observable<Void> {
    let productId = product.id ?? ""

    return store.user.take(1).map { user in
      let user = with(user) { $0.products = $0.products.filter({ $0 != productId }) }
      Database.save(user)
      Database.delete(self.product)
    }
  }
}
