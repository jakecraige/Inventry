import Delta

struct AddToCurrentOrder: ActionType {
  let product: Product

  func reduce(state: AppState) -> AppState {
    guard let productId = product.id else { return state }

    state.order.value.add(lineItem: LineItem(productId: productId))

    return state
  }
}
