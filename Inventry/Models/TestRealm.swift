import RealmSwift

// Models: User, Product, List, Order

final class RCharge: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var stripeID: String = ""
  dynamic var amount: Cents = 0
  dynamic var currency: String = Currency.USD.rawValue
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RCustomer: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var name: String = ""
  dynamic var email: String?
  dynamic var phone: String?
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RLineItem: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var product: RProduct?
  dynamic var quantity: Int = 0
  dynamic var name: String = "" 
  dynamic var price: Cents = 0
  dynamic var currency: String = Currency.USD.rawValue
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class ROrder: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var paymentToken: String = ""
  dynamic var notes: String = ""
  dynamic var taxRate: Float = Config.defaultTaxRate
  dynamic var shippingRate: Float = Config.defaultShippingRate
  dynamic var user: RUser?
  dynamic var charge: RCharge?
  dynamic var customer: RCustomer?
  let lineItems = RealmSwift.List<RLineItem>()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RProduct: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var name: String = ""
  dynamic var barcode: String = ""
  dynamic var quantity: Int = 0
  dynamic var price: Cents = 0
  dynamic var currency: String = Currency.USD.rawValue
  dynamic var user: RUser?
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RListUser: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var list: RList?
  dynamic var user: RUser?
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RListProduct: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var list: RList?
  dynamic var product: RProduct?
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RList: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var name: String = ""
  dynamic var user: RUser?
  let products = RealmSwift.List<RListProduct>()
  let users = RealmSwift.List<RListUser>()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

final class RUser: Object {
  dynamic var id: String = NSUUID().uuidString
  dynamic var name = ""
  let products = RealmSwift.List<RProduct>()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
