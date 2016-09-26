import Delta

struct DecrementFromCurrentOrder: ActionType {
  let product: Product

  func reduce(state: AppState) -> AppState {
    state.order.value.removeOrDecrement(
      lineItem: LineItem.from(product: product)
    )

    return state
  }
}
