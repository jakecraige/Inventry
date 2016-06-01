import Delta

struct ResetCurrentOrder: ActionType {
  func reduce(state: AppState) -> AppState {
    state.order.value = Order.new()

    return state
  }
}
