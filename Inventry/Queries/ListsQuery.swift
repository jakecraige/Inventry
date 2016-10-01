import RxSwift

struct ListsQuery: Query {
  let user: Observable<User>

  func build() -> Observable<[List]> {
    return user.flatMapLatest { user in
      return self.getAllLists(user: user)
    }
  }

  func getAllLists(user: User) -> Observable<[List]> {
    return Database.observe(refs: user.lists.map(List.getChildRef))
  }
}
