import RxSwift
import RxCocoa
import Firebase

// MARK: Getters
extension Store {
  var order: Observable<Order> {
    return state.value.order.asObservable()
  }

  var orderViewModel: Observable<OrderViewModel> {
    return order.map(OrderViewModel.init)
  }

  var isSignedIn: Bool {
    return state.value.firUser.value != .none
  }

  var signedIn: Driver<Bool> {
    return state.value.firUser.asObservable().map { user in
      return user != .none
    }.asDriver(onErrorJustReturn: false)
  }

  var firUser: Observable<FIRUser> {
    return state.value.firUser.asObservable()
      .filter { $0 != .none }
      .map { $0! }
  }

  var user: Observable<User> {
    return state.value.user.asObservable()
      .filter { $0 != .none }
      .map { $0! }
  }
}
