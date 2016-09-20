import Argo
import Curry
import Runes

struct Customer {
  let name: String
  let email: String?
  let phone: String?

  static func null() -> Customer {
    return Customer(name: "", email: .none, phone: .none)
  }
}

extension Customer: Decodable {
  static func decode(_ json: JSON) -> Decoded<Customer> {
    return curry(Customer.init)
      <^> json <| "name"
      <*> json <|? "email"
      <*> json <|? "phone"
  }
}

extension Customer: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name as AnyObject,
      "email": email as AnyObject? ?? "" as AnyObject,
      "phone": phone as AnyObject? ?? "" as AnyObject
    ]
  }
}
