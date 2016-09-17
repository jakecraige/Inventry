import Curry
import Argo

struct User: Modelable {
  let id: String?
  let uid: String
  var name: String
  var products = [String]()
  var orders = [String]()
  var stripeConnectAccount: StripeConnectAccount

  var accountSetupComplete: Bool {
    return !stripeConnectAccount.stripeUserID.isEmpty
  }

  init(
    id: String,
    name: String,
    products: [String] = [],
    orders: [String] = [],
    stripeConnectAccount: StripeConnectAccount = .null()
  ) {
    self.id = id
    self.uid = id
    self.name = name
    self.products = products
    self.orders = orders
    self.stripeConnectAccount = stripeConnectAccount
  }
}

extension User: Decodable {
  static func decode(json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> decodeFIRArray(json, key: "Products")
      <*> decodeFIRArray(json, key: "Orders")
      <*> (json <| "stripe_connect_account").or(.Success(.null()))
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name,
      "stripe_connect_account": stripeConnectAccount.encode()
    ]
      + products.FIR_encode(Product.refName)
      + orders.FIR_encode(Order.refName)
  }
}
