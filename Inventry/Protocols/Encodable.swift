protocol Encodable {
  /// Returns a dictionary encoding of this object with type `[String: Any]`
  func encode() -> AnyObject
}