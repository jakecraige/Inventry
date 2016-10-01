import Argo
import Curry
import Runes

struct ListProduct: FIRNestedArray {
  let product: String
  var quantity: Int

  static func encodeArray(_ items: [ListProduct]) -> AnyObject {
    var dict = [String: AnyObject]()
    items.forEach { item in
      dict[item.product] = item.encode() as AnyObject
    }
    return dict as AnyObject
  }
}

extension ListProduct: Encodable {
  func encode() -> [String : AnyObject] {
    return [
      "product": product as AnyObject,
      "quantity": quantity as AnyObject,
    ]
  }
}

extension ListProduct: Equatable {
  static func == (lhs: ListProduct, rhs: ListProduct) -> Bool {
    return lhs.product == rhs.product
  }
}

extension ListProduct: Decodable {
  static func decode(_ json: JSON) -> Decoded<ListProduct> {
    let new = curry(ListProduct.init)
    return new
      <^> json <| "product"
      <*> json <| "quantity"
  }
}

struct List: Modelable, Timestampable {
  var id: String?
  var name: String
  var userId: String
  var products: [ListProduct]
  var users: [String]
  let timestamps: Timestamps?

  static func new() -> List {
    return self.init(
      id: .none,
      name: "",
      userId: "",
      products: [],
      users: [],
      timestamps: .none
    )
  }
}

extension List: Decodable {
  static func decode(_ json: JSON) -> Decoded<List> {
    let new = curry(List.init)
    return new
      <^> json <|? "id"
      <*> json <| "name"
      <*> json <| "user_id"
      <*> json <|| "products"
      <*> decodeFIRArray(json: json, key: "users")
      <*> json <|? "timestamps"
  }
}

extension List: Encodable {
  func encode() -> [String: AnyObject] {
    var dict = [String: AnyObject]()
    dict["name"] = name as AnyObject
    dict["user_id"] = userId as AnyObject
    dict["users"] = users.FIR_encode() as AnyObject
    dict["products"] = ListProduct.encodeArray(products)
    return dict
  }
}
