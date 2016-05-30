import Argo
import Curry

struct Charge {
  let stripeID: String
  let amount: Cents
  let currency: Currency
}

extension Charge: Decodable {
  static func decode(json: JSON) -> Decoded<Charge> {
    return curry(Charge.init)
      <^> (json <| "stripe_id").or(json <| "id") // Firebase stores as `stripe_id`, API returns `id`
      <*> json <| "amount"
      <*> json <| "currency"
  }
}

extension Charge: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "stripe_id": stripeID,
      "amount": amount,
      "currency": currency.rawValue
    ]
  }
}
