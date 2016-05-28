import Argo
import Curry

struct Order: Modelable {
  let id: String?
  var lineItems: [LineItem] = []
  var paymentToken: String?
  var charge: Charge?

  static func new() -> Order {
    return self.init(id: .None, lineItems: [], paymentToken: .None, charge: .None)
  }

  func contains(lineItem: LineItem) -> Bool {
    return lineItems.contains(lineItem)
  }

  mutating func add(lineItem lineItem: LineItem) {
    lineItems.append(lineItem)
  }

  mutating func remove(lineItem lineItem: LineItem) {
    guard let index = lineItems.indexOf(lineItem) else { return }
    lineItems.removeAtIndex(index)
  }

  func calculateAmount(products: [Product]) -> Cents {
    return 500
  }
}

extension Order: Decodable {
  static func decode(json: JSON) -> Decoded<Order> {
    return curry(Order.init)
      <^> json <|? "id"
      <*> json <|| "line_items"
      <*> json <|? "payment_token"
      <*> json <|? "charge"
  }
}

extension Order: Encodable {
  func encode() -> AnyObject {
    var dict = [String: AnyObject]()
    dict["payment_token"] = paymentToken
    dict["line_items"] = LineItem.encodeArray(lineItems)
    dict["charge"] = charge?.encode()
    return dict
  }
}