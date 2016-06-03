import Delta

struct SetAllOrders: ActionType {
  let orders: [Order]

  func reduce(state: AppState) -> AppState {
    state.allOrders.value = orders

    return state
  }
}
