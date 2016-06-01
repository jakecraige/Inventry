import Delta

struct SetAllProducts: ActionType {
  let products: [Product]

  func reduce(state: AppState) -> AppState {
    state.allProducts.value = products

    return state
  }
}
