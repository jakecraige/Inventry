import Foundation

protocol Encodable {
  /// Returns a dictionary encoding of this object
  func encode() -> [String: AnyObject]
}
