import Delta
import Firebase
import RxSwift

struct SaveProduct: DynamicActionType {
  let product: Product

  func call() -> Observable<Product> {
    return store.user.take(1).map { user in
      let product = with(self.product) { $0.userId = user.uid }
      let id = Database.save(product)

      let user = with(user) { $0.products.append(id) }
      Database.save(user)
      return product
    }
  }
}
