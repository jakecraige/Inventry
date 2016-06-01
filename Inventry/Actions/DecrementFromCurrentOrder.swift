import Delta

struct DecrementFromCurrentOrder: ActionType {
  let product: Product

  func reduce(state: AppState) -> AppState {
    guard let productId = product.id else { return state }

    state.order.value.removeOrDecrement(lineItem: LineItem(productId: productId))

    return state
  }
}
