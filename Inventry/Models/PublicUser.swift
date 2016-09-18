import Curry
import Argo

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
  static func decode(json: JSON) -> Decoded<PublicUser> {
    return curry(self.init)
      <^> json <| "id"
      <*> json <| "name"
      <*> decodeFIRArray(json, key: "inventorySharedWith").or(pure([]))
      <*> decodeFIRArray(json, key: "inventorySharedFrom").or(pure([]))
  }
}

extension PublicUser: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name,
      "inventorySharedWith": inventorySharedWith.FIR_encode(),
      "inventorySharedFrom": inventorySharedFrom.FIR_encode(),
    ]
  }
}
