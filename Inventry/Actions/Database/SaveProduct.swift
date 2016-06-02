import Delta
import Firebase
import RxSwift

struct SaveProduct: DynamicActionType {
  let product: Product
  let dispose = DisposeBag()

  func call() {
    let id = Database.save(product)
    store.user.map { user in
      Database.save(
        User(id: user.uid, products: [id])
      )
    }.subscribe().addDisposableTo(dispose)
  }
}
