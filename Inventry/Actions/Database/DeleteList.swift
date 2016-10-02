import Delta
import RxSwift
import Firebase

struct DeleteList: DynamicActionType {
  let list: List

  func call() -> Observable<Void> {
    return deleteUserListAccess()
      .flatMap { self.deleteUserProductsAccess() }
      .map { Database.delete(self.list) }
  }

  func deleteUserListAccess() -> Observable<Void> {
    let userIDs = (list.users + [list.userId])
    let deletions = userIDs
        .map { User.getChildRef($0).child("Lists/\(list.id!)") }
        .reduce([:]) { $0 + $1.removalDict }

    return Database.observeSave(deletions)
  }

  func deleteUserProductsAccess() -> Observable<Void> {
    // TODO: Only remove users who aren't also on another list that needs this product
    let deletions = list.products
      .map { Product.getChildRef($0.product).child("users") }
      .map { ref in list.users.map { ref.child($0) } }
      .flatMap { $0 }
      .reduce([:]) { $0 + $1.removalDict }

    return Database.observeSave(deletions)
  }
}
