import Argo
import Curry

struct Customer {
  let name: String
  let email: String?
  let phone: String?

  static func null() -> Customer {
    return Customer(name: "", email: .None, phone: .None)
  }
}

extension Customer: Decodable {
  static func decode(json: JSON) -> Decoded<Customer> {
    return curry(Customer.init)
      <^> json <| "name"
      <*> json <|? "email"
      <*> json <|? "phone"
  }
}

extension Customer: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name,
      "email": email ?? "",
      "phone": phone ?? ""
    ]
  }
}
