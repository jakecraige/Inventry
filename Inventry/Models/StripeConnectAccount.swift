import Argo
import Curry

struct StripeConnectAccount {
  let stripeUserID: String
  let stripePublishableKey: String
  let accessToken: String
  let refreshToken: String
  let scope: String
  let tokenType: String
  let livemode: Bool

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
  static func decode(json: JSON) -> Decoded<StripeConnectAccount> {
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
      "stripe_user_id": stripeUserID,
      "stripe_publishable_key": stripePublishableKey,
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "scope": scope,
      "token_type": tokenType,
      "livemode": livemode
    ]
  }
}
