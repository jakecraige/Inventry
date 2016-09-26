import Delta

struct RemoveFromCurrentOrder: ActionType {
  let product: Product

  func reduce(state: AppState) -> AppState {
    _ = state.order.value.remove(lineItem: LineItem.from(product: product))

    return state
  }
}
