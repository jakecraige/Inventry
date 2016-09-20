import Argo
import Curry
import Runes

struct Timestamps {
  let createdAt: Date
  let updatedAt: Date
}

extension Timestamps: Decodable {
  static func decode(_ json: JSON) -> Decoded<Timestamps> {
    return curry(Timestamps.init)
      <^> json <| "created_at"
      <*> json <| "updated_at"
  }
}
