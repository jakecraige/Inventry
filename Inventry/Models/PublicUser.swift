import Curry
import Argo
import Runes

struct PublicUser: Modelable {
  let id: String?
  var name: String
  var inventorySharedWith: [String]
  var inventorySharedFrom: [String]

  init(id: String, name: String, inventorySharedWith: [String] = [], inventorySharedFrom: [String] = []) {
    self.id = id
    self.name = name
    self.inventorySharedWith = inventorySharedWith
    self.inventorySharedFrom = inventorySharedFrom
  }
}

extension PublicUser: Decodable {
  static func decode(_ json: JSON) -> Decoded<PublicUser> {
    return curry(self.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> decodeFIRArray(json: json, key: "inventorySharedWith").or(pure([]))
      <*> decodeFIRArray(json: json, key: "inventorySharedFrom").or(pure([]))
  }
}

extension PublicUser: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name as AnyObject,
      "inventorySharedWith": inventorySharedWith.FIR_encode() as AnyObject,
      "inventorySharedFrom": inventorySharedFrom.FIR_encode() as AnyObject,
    ]
  }
}
