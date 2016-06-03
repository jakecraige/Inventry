import Curry
import Argo

struct User: Modelable {
  let id: String?
  var products = [String]()
  var orders = [String]()
}

extension User: Decodable {
  static func decode(json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <|? "id"
      <*> { .Success([]) }()
      <*> { .Success([]) }()
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [:]
      + products.FIR_encode(Product.refName)
      + orders.FIR_encode(Order.refName)
  }
}
