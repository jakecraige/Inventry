import Delta

struct IncrementCurrentOrder: ActionType {
  let lineItem: LineItem

  func reduce(state: AppState) -> AppState {
    state.order.value.increment(lineItem: lineItem)
    return state
  }
}
