import Delta
import Firebase
import RxSwift

struct SaveProduct: DynamicActionType {
  let product: Product

  func call() -> Observable<Product> {
    return store.user.take(1).map { user in
      var product = self.product

      // Since multiple users can save a product, we only want to set the user ID if it hasn't
      // already been set.
      if self.product.userId.isEmpty {
        product.userId = user.uid
        let id = Database.save(product)
        
        var newUser = user
        newUser.products.append(id)
        _ = Database.save(newUser)
      } else {
        _ = Database.save(product)
      }

      return product
    }
  }
}
