import Delta

struct ResetCurrentOrder: DynamicActionType {
  func call() {
    store.dispatch(SetOrder(order: Order.new()))
  }
}
