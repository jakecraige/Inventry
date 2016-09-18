import Firebase

extension FIRDataSnapshot {
  var asDictionary: [String: AnyObject] {
    guard var dict = value as? [String: AnyObject] else { return [:] }
    dict["id"] = key
    return dict
  }
}

extension CollectionType where Self.Generator.Element == String {
  /// Used to encode an array of IDs into `{"id": true, "id2": true}`.
  func FIR_encode() -> [String: AnyObject] {
    if isEmpty {
      return [:]
    } else {
      return reduce([:]) { result, key in
        return result + [key: true]
      }
    }
  }
}
