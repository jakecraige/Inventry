import Delta

struct UpdateCurrentOrder: ActionType {
  let shippingRate: Float?
  let taxRate: Float?
  let notes: String?

  init(shippingRate: Float? = .None, taxRate: Float? = .None, notes: String? = .None) {
    self.shippingRate = shippingRate
    self.taxRate = taxRate
    self.notes = notes
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

    return state
  }
}
