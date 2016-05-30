import Argo
import Curry

private let defaultNotes = ""

struct Order: Modelable, Timestampable {
  let id: String?
  var lineItems: [LineItem] = []
  var paymentToken: String?
  var charge: Charge?
  var customer: Customer?
  var taxRate: Float // Stored as a decimal 8.25% will be 0.0825
  var notes: String = defaultNotes
  let timestamps: Timestamps?

  static func new() -> Order {
    return self.init(
      id: .None,
      lineItems: [],
      paymentToken: .None,
      charge: .None,
      customer: .None,
      taxRate: Config.defaultTaxRate,
      notes: defaultNotes,
      timestamps: .None
    )
  }

  func contains(lineItem: LineItem) -> Bool {
    return lineItems.contains(lineItem)
  }

  func item(forProduct product: Product) -> LineItem? {
    return lineItems.find { $0.productId == (product.id ?? "") }
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

  mutating func increment(lineItem lineItem: LineItem) {
    if let existingItem = find(lineItem: lineItem) {
      replace(existingItem, withLineItem: existingItem.increment())
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
    return lineItems.find({$0.productId == lineItem.productId})
  }

  func calculateAmount(products: [Product]) -> Cents {
    return lineItems.reduce(0) { total, item in
      guard let product = products.find({($0.id ?? "") == item.productId}) else { return total }

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
      <*> (json <|  "tax_rate").or(.Success(Config.defaultTaxRate))
      <*> (json <|  "notes").or(.Success(defaultNotes))
      <*> json <|? "timestamps"
  }
}

extension Order: Encodable {
  func encode() -> [String: AnyObject] {
    var dict = [String: AnyObject]()
    dict["payment_token"] = paymentToken
    dict["line_items"] = LineItem.encodeArray(lineItems)
    dict["charge"] = charge?.encode()
    dict["customer"] = customer?.encode()
    dict["tax_rate"] = taxRate
    dict["notes"] = notes
    return dict
  }
}
