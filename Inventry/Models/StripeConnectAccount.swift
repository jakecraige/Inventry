import Argo
import Curry
import Runes

struct StripeConnectAccount {
  let stripeUserID: String
  let stripePublishableKey: String
  let accessToken: String
  let refreshToken: String
  let scope: String
  let tokenType: String
  let livemode: Bool

  var isNull: Bool {
    return stripeUserID.isEmpty
  }

  static func null() -> StripeConnectAccount {
    return .init(
      stripeUserID: "",
      stripePublishableKey: "",
      accessToken: "",
      refreshToken: "",
      scope: "",
      tokenType: "",
      livemode: false
    )
  }
}

extension StripeConnectAccount: Decodable {
  static func decode(_ json: JSON) -> Decoded<StripeConnectAccount> {
    return curry(StripeConnectAccount.init)
      <^> json <| "stripe_user_id"
      <*> json <| "stripe_publishable_key"
      <*> json <| "access_token"
      <*> json <| "refresh_token"
      <*> json <| "scope"
      <*> json <| "token_type"
      <*> json <| "livemode"
  }
}

extension StripeConnectAccount: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "stripe_user_id": stripeUserID as AnyObject,
      "stripe_publishable_key": stripePublishableKey as AnyObject,
      "access_token": accessToken as AnyObject,
      "refresh_token": refreshToken as AnyObject,
      "scope": scope as AnyObject,
      "token_type": tokenType as AnyObject,
      "livemode": livemode as AnyObject
    ]
  }
}
