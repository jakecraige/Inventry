import Delta

struct RemoveFromCurrentOrder: ActionType {
  let product: Product

  func reduce(state: AppState) -> AppState {
    guard let productId = product.id else { return state }

    state.order.value.remove(lineItem: LineItem(productId: productId))

    return state
  }
}
