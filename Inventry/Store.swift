import Delta
import RxSwift

struct Store: StoreType {
  var state: Variable<AppState>

  lazy var user: Observable<User> = {
    return self.firUser
      .flatMapLatest { Database.observeObject(ref: User.getChildRef($0.uid)) }
      .shareReplay(1)
  }()
}

let initialState = AppState()
var store = Store(state: Variable(initialState), user: nil)
