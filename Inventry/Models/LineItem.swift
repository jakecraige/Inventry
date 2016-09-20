import Argo
import Curry
import Runes

struct LineItem: FIRNestedArray {
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

  static func encodeArray(_ items: [LineItem]) -> AnyObject {
    var dict = [String: AnyObject]()
    items.forEach { item in
      dict[item.productId] = item.encode() as AnyObject
    }
    return dict as AnyObject
  }
}

extension LineItem: Decodable {
  static func decode(_ json: JSON) -> Decoded<LineItem> {
    return curry(LineItem.init)
      <^> json <| "product_id"
      <*> json <| "quantity"
  }
}

extension LineItem: Equatable { }

func == (lhs: LineItem, rhs: LineItem) -> Bool {
  return lhs.productId == rhs.productId
}

extension LineItem: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "product_id": productId as AnyObject,
      "quantity": quantity as AnyObject
    ]
  }
}
