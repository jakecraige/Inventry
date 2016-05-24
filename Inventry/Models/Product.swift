import Argo
import Curry
import Firebase

struct Product: Modelable {
  let id: String?
  let name: String
  let isbn: String
  let quantity: Int
  let price: Float
}

extension Product: Decodable {
  static func decode(json: JSON) -> Decoded<Product> {
    return curry(Product.init)
      <^> json <|? "id"
      <*> json <| "name"
      <*> json <| "isbn"
      <*> json <| "quantity"
      <*> json <| "price"
  }
}

extension Product: Encodable {
  func encode() -> AnyObject {
    return [
      "name": name,
      "isbn": isbn,
      "quantity": quantity,
      "price": price,
    ]
  }
}