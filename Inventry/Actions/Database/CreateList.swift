import Delta
import Firebase
import RxSwift

struct CreateList: DynamicActionType {
  let name: String
  let newList: NewList

  // 1. Create list
  // 2. Add user(s) products access
  // 3. Add user(s) list access
  func call() -> Observable<List> {
    return store.user.take(1).map { user in
      return (user, self.initializeList(user: user))
    }.flatMap { user, list in
      return Database.observeSave(list).flatMap { list in
        return self.updateDenormalized(list: list, user: user)
      }
    }
  }

  private func initializeList(user: User) -> List {
    return List(
      id: .none,
      name: name,
      userId: user.uid,
      products: newList.products,
      users: newList.users.map { $0.id! },
      timestamps: .none
    )
  }

  private func updateDenormalized(list: List, user: User) -> Observable<List> {
    let dict = updateDictionary(list: list, user: user).deepFlatten()
    return Database.observeSave(dict).map { _ in list }
  }
  
  private func updateDictionary(list: List, user: User) -> [String: AnyObject] {
    let newUserVal = addToUserList(list: list, user: user)
    let newUserListsVal = newList.users.reduce([:]) { acc, puser in
      return acc + addToUserList(list: list, userId: puser.id!)
    }
    let newProductsUsersList = newList.products.reduce([:]) { acc, listProduct in
      return acc + addToUsersToProduct(productId: listProduct.product, users: newList.users)
    }
    
    let updates = newUserVal + newUserListsVal + newProductsUsersList
    return updates
  }


  private func addToUserList(list: List, user: User) -> [String: AnyObject] {
    var newUser = user
    newUser.lists.append(list.id!)
    return Database.valuesForUpdate(newUser, includeRootKey: true, selectKeys: ["Lists"])
  }

  private func addToUserList(list: List, userId: String) -> [String: AnyObject] {
    return addToUserList(list: list, user: User(id: userId))
  }

  private func addToUsersToProduct(productId: String, users: [PublicUser]) -> [String: AnyObject] {
    var newProduct = Product.fromID(id: productId)
    users.forEach { user in
      newProduct.users.append(user.id!)
    }
    return Database.valuesForUpdate(newProduct, includeRootKey: true, selectKeys: ["users"])
  }
}
