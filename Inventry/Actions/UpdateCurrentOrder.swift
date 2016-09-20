import Delta

struct UpdateCurrentOrder: ActionType {
  let shippingRate: Float?
  let taxRate: Float?
  let notes: String?
  let customer: Customer?
  let paymentToken: String?

  init(
    shippingRate: Float? = .none,
    taxRate: Float? = .none,
    notes: String? = .none,
    customer: Customer? = .none,
    paymentToken: String? = .none
  ) {
    self.shippingRate = shippingRate
    self.taxRate = taxRate
    self.notes = notes
    self.customer = customer
    self.paymentToken = paymentToken
  }

  func reduce(state: AppState) -> AppState {
    if let shippingRate = shippingRate {
      state.order.value.shippingRate = shippingRate
    }
    if let taxRate = taxRate {
      state.order.value.taxRate = taxRate
    }
    if let notes = notes {
      state.order.value.notes = notes
    }
    if let customer = customer {
      state.order.value.customer = customer
    }
    if let paymentToken = paymentToken {
      state.order.value.paymentToken = paymentToken
    }

    return state
  }
}
