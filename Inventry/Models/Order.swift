import Argo
import Curry
import Runes

private let defaultNotes = ""

struct Order: Modelable, Timestampable {
  var id: String?
  var lineItems: [LineItem] = []
  var paymentToken: String?
  var charge: Charge?
  var customer: Customer?
  var taxRate: Float // Stored as a decimal 8.25% will be 0.0825
  var shippingRate: Float // Stored as a decimal 8.00% will be 0.08
  var notes: String = defaultNotes
  let timestamps: Timestamps?
  var userId: String

  static func new() -> Order {
    return self.init(
      id: .none,
      lineItems: [],
      paymentToken: .none,
      charge: .none,
      customer: .none,
      taxRate: Config.defaultTaxRate,
      shippingRate: Config.defaultShippingRate,
      notes: defaultNotes,
      timestamps: .none,
      userId: ""
    )
  }

  func contains(_ lineItem: LineItem) -> Bool {
    return lineItems.contains(lineItem)
  }

  func item(forProduct product: Product) -> LineItem? {
    return lineItems.find { $0.productId == (product.id ?? "") }
  }

  mutating func add(lineItem: LineItem, atIndex index: Int? = .none) {
    if let index = index {
      lineItems.insert(lineItem, at: index)
    } else {
      lineItems.append(lineItem)
    }
  }

  mutating func remove(lineItem: LineItem) -> Int? {
    guard let index = lineItems.index(of: lineItem) else { return .none }
    lineItems.remove(at: index)
    return index
  }

  mutating func replace(_ oldLineItem: LineItem, withLineItem newLineItem: LineItem) {
    let index = remove(lineItem: oldLineItem)
    add(lineItem: newLineItem, atIndex: index)
  }

  mutating func increment(lineItem: LineItem) {
    if let existingItem = find(lineItem: lineItem) {
      replace(existingItem, withLineItem: existingItem.increment())
    }
  }

  /// Decrement line item quantity if it exists and is above one, remove otherwise
  mutating func removeOrDecrement(lineItem: LineItem) {
    guard let existingItem = find(lineItem: lineItem) else { return }

    if existingItem.quantity > 1 {
      replace(existingItem, withLineItem: existingItem.decrement())
    } else {
      _ = remove(lineItem: lineItem)
    }
  }

  fileprivate func find(lineItem: LineItem) -> LineItem? {
    return lineItems.find({$0.productId == lineItem.productId})
  }

  func calculateAmount(_ products: [Product]) -> Cents {
    return lineItems.reduce(0) { total, item in
      guard let product = products.find({($0.id ?? "") == item.productId}) else { return total }

      return total + (product.price * item.quantity)
    }
  }
}

extension Order: Decodable {
  static func decode(_ json: JSON) -> Decoded<Order> {
    let new = curry(Order.init)
    return new
      <^> json <|? "id"
      <*> json <|| "line_items"
      <*> json <|? "payment_token"
      <*> json <|? "charge"
      <*> json <|? "customer"
      <*> (json <| "tax_rate").or(.success(Config.defaultTaxRate))
      <*> (json <| "shipping_rate").or(.success(Config.defaultShippingRate))
      <*> (json <| "notes").or(.success(defaultNotes))
      <*> json <|? "timestamps"
      <*> json <| "user_id"
  }
}

extension Order: Encodable {
  func encode() -> [String: AnyObject] {
    var dict = [String: AnyObject]()
    dict["payment_token"] = paymentToken as AnyObject?
    dict["line_items"] = LineItem.encodeArray(lineItems)
    dict["charge"] = charge?.encode() as AnyObject?
    dict["customer"] = customer?.encode() as AnyObject?
    dict["tax_rate"] = taxRate as AnyObject?
    dict["shipping_rate"] = shippingRate as AnyObject?
    dict["notes"] = notes as AnyObject?
    dict["user_id"] = userId as AnyObject?
    return dict
  }
}
