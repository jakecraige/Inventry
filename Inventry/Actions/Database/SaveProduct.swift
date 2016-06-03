import Delta
import Firebase
import RxSwift

struct SaveProduct: DynamicActionType {
  let product: Product
  let dispose = DisposeBag()

  func call() {
    var product = self.product
    store.user.subscribeNext { user in
      product.userId = user.uid
      let id = Database.save(product)
      Database.save(User(id: user.uid, products: [id], orders: []))
    }.addDisposableTo(dispose)
  }
}