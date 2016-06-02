import Curry
import Argo

struct User: Modelable {
  let id: String?
  var products = [String]()
}

extension User: Decodable {
  static func decode(json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <|? "id"
      <*> { .Success([]) }()
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "Orders": true,
    ] + products.FIR_encode(Product.refName)
  }
}
