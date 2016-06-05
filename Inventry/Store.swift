import Delta
import RxSwift

struct Store: StoreType {
  var state: Variable<AppState>
}

let initialState = AppState()
var store = Store(state: Variable(initialState))
