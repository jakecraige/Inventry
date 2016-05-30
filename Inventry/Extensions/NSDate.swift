import Argo

extension NSDate: Decodable {
  public static func decode(json: JSON) -> Decoded<NSDate> {
    switch json {
    case let .Number(timestampInMilliseconds):
      let timestampInSeconds = Double(timestampInMilliseconds) / 1000
      return pure(NSDate(timeIntervalSince1970: timestampInSeconds))
    default:
      return .typeMismatch("Number", actual: json)
    }
  }
}
