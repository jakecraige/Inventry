import Argo
import Curry

struct LineItem {
  let productId: String
  let quantity: Int

  init(productId: String, quantity: Int = 1) {
    self.productId = productId
    self.quantity = quantity
  }

  func increment() -> LineItem {
    return LineItem(productId: productId, quantity: quantity + 1)
  }

  func decrement() -> LineItem {
    return LineItem(productId: productId, quantity: quantity - 1)
  }
}

extension LineItem: Decodable {
  static func decode(json: JSON) -> Decoded<LineItem> {
    return curry(LineItem.init)
      <^> json <| "product_id"
      <*> json <| "quantity"
  }
}

extension LineItem: Equatable { }

func == (lhs: LineItem, rhs: LineItem) -> Bool {
  return lhs.productId == rhs.productId
}
