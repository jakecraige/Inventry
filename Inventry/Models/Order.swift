import Argo
import Curry

struct Order: Modelable {
  let id: String?
  var lineItems: [LineItem] = []

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
}

extension Order: Decodable {
  static func decode(json: JSON) -> Decoded<Order> {
    return curry(Order.init)
      <^> json <|? "id"
      <*> json <|| "line_items"
  }
}

extension Order: Encodable {
  func encode() -> AnyObject {
    return [:]
  }
}