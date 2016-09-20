import Curry
import Argo
import Runes

struct User: Modelable {
  let id: String?
  let uid: String
  var products = [String]()
  var orders = [String]()
  var stripeConnectAccount: StripeConnectAccount

  var accountSetupComplete: Bool {
    return !stripeConnectAccount.stripeUserID.isEmpty
  }

  init(
    id: String,
    products: [String] = [],
    orders: [String] = [],
    stripeConnectAccount: StripeConnectAccount = .null()
  ) {
    self.id = id
    self.uid = id
    self.products = products
    self.orders = orders
    self.stripeConnectAccount = stripeConnectAccount
  }
}

extension User: Decodable {
  static func decode(_ json: JSON) -> Decoded<User> {
    return curry(User.init)
      <^> json <| "id"
      <*> decodeFIRArray(json: json, key: "Products").or(pure([]))
      <*> decodeFIRArray(json: json, key: "Orders").or(pure([]))
      <*> (json <| "stripe_connect_account").or(.success(.null()))
  }
}

extension User: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "stripe_connect_account": stripeConnectAccount.encode() as AnyObject,
      "Products": products.FIR_encode() as AnyObject,
      "Orders": orders.FIR_encode() as AnyObject
    ]
  }
}
