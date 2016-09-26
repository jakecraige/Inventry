import Argo
import Curry
import Runes

struct LineItem: FIRNestedArray {
  let productId: String
  let quantity: Int
  let name: String
  let price: Cents
  let currency: Currency

  static func from(product: Product) -> LineItem {
    guard let productID = product.id else {
      fatalError("Attempted to add non-saved product to an order.")
    }

    return LineItem(
      productId: productID,
      quantity: 1,
      name: product.name,
      price: product.price,
      currency: product.currency
    )
  }

  func increment() -> LineItem {
    return LineItem(
      productId: productId,
      quantity: quantity + 1,
      name: name,
      price: price,
      currency: currency
    )
  }

  func decrement() -> LineItem {
    return LineItem(
      productId: productId,
      quantity: quantity - 1,
      name: name,
      price: price,
      currency: currency
    )
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
      <*> json <| "name"
      <*> json <| "price"
      <*> json <| "currency"
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
      "quantity": quantity as AnyObject,
      "name": name as AnyObject,
      "price": price as AnyObject,
      "currency": currency.rawValue as AnyObject,
    ]
  }
}
