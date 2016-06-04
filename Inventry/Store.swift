import Delta
import RxSwift

struct Store: StoreType {
  var state: Variable<AppState>

  lazy var user: Observable<User> = {
    return self.firUser
      .flatMapLatest { Database.observeObject(ref: User.getChildRef($0.uid)) }
      .share()
  }()
}

let initialState = AppState()
var store = Store(state: Variable(initialState), user: nil)
