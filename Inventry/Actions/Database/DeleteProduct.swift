import Delta
import Firebase
import RxSwift

struct DeleteProduct: DynamicActionType {
  let product: Product

  func call() -> Observable<Void> {
    let productId = product.id ?? ""

    return store.user.take(1).map { user in
      var newUser = user
      newUser.products = user.products.filter({ $0 != productId })
      
      _ = Database.save(newUser)
      Database.delete(self.product)
    }
  }
}
