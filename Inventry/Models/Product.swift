import Argo
import Curry
import Firebase
import Runes

struct Product: Modelable {
  var id: String?
  let name: String
  let barcode: String
  let quantity: Int
  let price: Cents
  let currency: Currency
  var userId: String
  var users: [String] = []

  func decrement(by decrementDelta: Int = 1) -> Product {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      quantity: quantity - decrementDelta,
      price: price,
      currency: currency,
      userId: userId,
      users: users
    )
  }

  static func fromID(id: String) -> Product {
    return Product(
      id: id,
      name: "",
      barcode: "",
      quantity: 0,
      price: 0,
      currency: Currency.USD,
      userId: "",
      users: []
    )
  }
}

extension Product: Decodable {
  static func decode(_ json: JSON) -> Decoded<Product> {
    return curry(Product.init)
      <^> json <|? "id"
      <*> json <| "name"
      <*> json <| "barcode"
      <*> json <| "quantity"
      <*> json <| "price"
      <*> json <| "currency"
      <*> json <| "user_id"
      <*> decodeFIRArray(json: json, key: "users").or(pure([]))
  }
}

extension Product: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name as AnyObject,
      "barcode": barcode as AnyObject,
      "quantity": quantity as AnyObject,
      "price": price as AnyObject,
      "currency": currency.rawValue as AnyObject,
      "user_id": userId as AnyObject,
      "users": users.FIR_encode() as AnyObject
    ]
  }
}
