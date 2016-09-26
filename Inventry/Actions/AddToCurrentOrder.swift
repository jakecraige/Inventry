import Delta

struct AddToCurrentOrder: ActionType {
  let product: Product

  func reduce(state: AppState) -> AppState {
    state.order.value.add(lineItem: LineItem.from(product: product))

    return state
  }
}
