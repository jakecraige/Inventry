import Curry
import Argo

struct User: Modelable {
  let id: String?
  let uid: String
  var products = [String]()
  var orders = [String]()
  var stripeAccessToken: String

  var accountSetupComplete: Bool {
    return !stripeAccessToken.isEmpty
  }

  init(id: String, products: [String] = [], orders: [String] = [], stripeAccessToken: String = "") {
    self.id = id
    self.uid = id
    self.products = products
    self.orders = orders
    self.stripeAccessToken = stripeAccessToken
  }
}

extension User: Decodable {
  static func decode(json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <| "id"
      <*> decodeFIRArray(json, key: "Products")
      <*> decodeFIRArray(json, key: "Orders")
      <*> (json <| "stripe_access_token").or(.Success(""))
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [:]
      + products.FIR_encode(Product.refName)
      + orders.FIR_encode(Order.refName)
      + ["stripe_access_token": stripeAccessToken]
  }
}
