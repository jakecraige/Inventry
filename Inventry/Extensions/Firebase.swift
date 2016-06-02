import Firebase

extension FIRDataSnapshot {
  var asDictionary: [String: AnyObject] {
    guard var dict = value as? [String: AnyObject] else { return [:] }
    dict["id"] = key
    return dict
  }
}

extension CollectionType where Self.Generator.Element == String {
  /// Used to encode an array of IDs into {"model/id": true}. The prefix is used to we aren't
  /// accidentally doing overwrites on existing data.
  func FIR_encode(refPrefix: String) -> [String: Bool] {
    return reduce([:]) { result, key in
      var dict = result
      dict["\(refPrefix)/\(key)"] = true
      return dict
    }
  }
}
