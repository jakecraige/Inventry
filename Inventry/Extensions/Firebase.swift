import Firebase

extension FIRDataSnapshot {
  var asDictionary: [String: AnyObject] {
    guard var dict = value as? [String: AnyObject] else { return [:] }
    dict["id"] = key
    return dict
  }
}

extension CollectionType where Self.Generator.Element == String {
  /// Used to encode an array of IDs into `{"model": {"id": true}}`.
  func FIR_encode(refPrefix: String) -> [String: AnyObject] {
    if isEmpty {
      return [refPrefix: true]
    } else {
      let subDict = reduce([:]) { result, key in
        return result + [key: true]
      }
      return [refPrefix: subDict]
    }
  }
}
