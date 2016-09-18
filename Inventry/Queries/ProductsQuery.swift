import RxSwift

struct ProductsQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[Product]> {
    return user.flatMapLatest { user in
      return self.getAllInventory(user)
    }.map { products in
      return products.sort { $0.name < $1.name }
    }
  }

  func getAllInventory(user: User) -> Observable<[Product]> {
    return Observable.combineLatest(getInventoryProducts(user), getSharedInventoryProducts(user.uid)) {
      return $0 + $1
    }
  }

  func getInventoryProducts(user: User) -> Observable<[Product]> {
    return Database.observe(refs: user.products.map(Product.getChildRef))
  }

  func getSharedInventoryProducts(userID: String) -> Observable<[Product]> {
    let query = PublicUserQuery(id: userID).build()

    return query.flatMapLatest { user in
      return self.productIDs(forIDs: user.inventorySharedFrom)
    }.flatMapLatest { productIDs -> Observable<[Product]> in
      return Database.observe(refs: productIDs.map(Product.getChildRef))
    }
  }

  private func productIDs(forIDs ids: [String]) -> Observable<[String]> {
    return ids.map { id in
      return User.getChildRef(id).child("Products")
    }.map { ref in
      return Database.observe(ref: ref)
    }.combineLatest { Array($0.flatten()) }
  }
}
