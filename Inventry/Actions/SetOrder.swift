import Delta

struct SetOrder: ActionType {
  let order: Order

  func reduce(state: AppState) -> AppState {
    state.order.value = order

    return state
  }
}
