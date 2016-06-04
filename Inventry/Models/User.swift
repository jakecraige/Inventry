import Curry
import Argo

struct User: Modelable {
  let id: String?
  let uid: String
  var products = [String]()
  var orders = [String]()

  init(id: String, products: [String] = [], orders: [String] = []) {
    self.id = id
    self.uid = id
    self.products = products
    self.orders = orders
  }
}

extension User: Decodable {
  static func decode(json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <| "id"
      <*> decodeFIRArray(json, key: "Products")
      <*> decodeFIRArray(json, key: "Orders")
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [:]
      + products.FIR_encode(Product.refName)
      + orders.FIR_encode(Order.refName)
  }
}
