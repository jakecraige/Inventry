import Argo
import Curry
import Firebase

struct Product {
  let id: String?
  let name: String
  let isbn: String
  let quantity: Int
  let price: Float
}

extension Product: Decodable, Queryable {
  static func decode(json: JSON) -> Decoded<Product> {
    return curry(Product.init)
      <^> json <|? "id"
      <*> json <| "name"
      <*> json <| "isbn"
      <*> json <| "quantity"
      <*> json <| "quantity"
  }
}

extension Product: Encodable {
  func encode() -> AnyObject? {
    return [
      "name": name,
      "isbn": isbn,
      "quantity": quantity,
      "price": price,
    ]
  }
}