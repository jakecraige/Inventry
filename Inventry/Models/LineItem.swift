import Argo
import Curry

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

  static func encodeArray(items: [LineItem]) -> AnyObject {
    return items.reduce([String: AnyObject]()) { dict, item in
      var mutableDict = dict
      mutableDict[item.productId] = item.encode()
      return mutableDict
    }
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

extension LineItem: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "product_id": productId,
      "quantity": quantity
    ]
  }
}
