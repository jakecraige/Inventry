import Argo
import Curry

struct Order: Modelable {
  let id: String?
}

extension Order: Decodable {
  static func decode(json: JSON) -> Decoded<Order> {
    return curry(Order.init)
      <^> json <|? "id"
  }
}

extension Order: Encodable {
  func encode() -> AnyObject {
    return [:]
  }
}