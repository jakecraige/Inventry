import Curry
import Argo

struct PublicUser: Modelable {
  let id: String?
  var name: String

  init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

extension PublicUser: Decodable {
  static func decode(json: JSON) -> Decoded<PublicUser> {
    return curry(self.init)
      <^> json <| "id"
      <*> json <| "name"
  }
}

extension PublicUser: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name,
    ]
  }
}
