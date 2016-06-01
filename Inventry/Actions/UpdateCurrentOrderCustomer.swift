import Delta

struct UpdateCurrentOrderCustomer: ActionType {
  let name: String?
  let phone: String?
  let email: String?

  init(name: String? = .None, phone: String? = .None, email: String? = .None) {
    self.name = name
    self.phone = phone
    self.email = email
  }

  func reduce(state: AppState) -> AppState {
    let currentCustomer = state.order.value.customer ?? Customer.null()
    state.order.value.customer = Customer(
      name: name ?? currentCustomer.name,
      email: email ?? currentCustomer.email,
      phone: phone ?? currentCustomer.phone
    )

    return state
  }
}
