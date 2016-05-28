import Argo
import Curry

struct Order: Modelable {
  let id: String?
  var lineItems: [LineItem] = []
  var paymentToken: String?
  var charge: Charge?
  var customer: Customer?

  static func new() -> Order {
    return self.init(id: .None, lineItems: [], paymentToken: .None, charge: .None, customer: .None)
  }

  func contains(lineItem: LineItem) -> Bool {
    return lineItems.contains(lineItem)
  }

  func item(forProduct product: Product) -> LineItem? {
    return lineItems.filter { $0.productId == (product.id ?? "") }.first
  }

  mutating func add(lineItem lineItem: LineItem, atIndex index: Int? = .None) {
    if let index = index {
      lineItems.insert(lineItem, atIndex: index)
    } else {
      lineItems.append(lineItem)
    }
  }

  mutating func remove(lineItem lineItem: LineItem) -> Int? {
    guard let index = lineItems.indexOf(lineItem) else { return .None }
    lineItems.removeAtIndex(index)
    return index
  }

  mutating func replace(oldLineItem: LineItem, withLineItem newLineItem: LineItem) {
    let index = remove(lineItem: oldLineItem)
    add(lineItem: newLineItem, atIndex: index)
  }

  /// Add line item if it doesn't exist, increment quantity otherwise
  mutating func addOrIncrement(lineItem lineItem: LineItem) {
    if let existingItem = find(lineItem: lineItem) {
      replace(existingItem, withLineItem: existingItem.increment())
    } else {
      add(lineItem: lineItem)
    }
  }

  /// Decrement line item quantity if it exists and is above one, remove otherwise
  mutating func removeOrDecrement(lineItem lineItem: LineItem) {
    guard let existingItem = find(lineItem: lineItem) else { return }

    if existingItem.quantity > 1 {
      replace(existingItem, withLineItem: existingItem.decrement())
    } else {
      remove(lineItem: lineItem)
    }
  }

  private func find(lineItem lineItem: LineItem) -> LineItem? {
    return lineItems.filter({$0.productId == lineItem.productId}).first
  }

  func calculateAmount(products: [Product]) -> Cents {
    return lineItems.reduce(0) { total, item in
      guard let product = products.filter({($0.id ?? "") == item.productId}).first else { return total }

      return total + (product.price * item.quantity)
    }
  }
}

extension Order: Decodable {
  static func decode(json: JSON) -> Decoded<Order> {
    return curry(Order.init)
      <^> json <|? "id"
      <*> json <|| "line_items"
      <*> json <|? "payment_token"
      <*> json <|? "charge"
      <*> json <|? "customer"
  }
}

extension Order: Encodable {
  func encode() -> AnyObject {
    var dict = [String: AnyObject]()
    dict["payment_token"] = paymentToken
    dict["line_items"] = LineItem.encodeArray(lineItems)
    dict["charge"] = charge?.encode()
    dict["customer"] = customer?.encode()
    return dict
  }
}
