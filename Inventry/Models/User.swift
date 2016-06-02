import Curry
import Argo

struct User: Modelable {
  let id: String?
}

extension User: Decodable {
  static func decode(json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <|? "id"
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "products": true,
      "orders": true,
    ]
  }
}
