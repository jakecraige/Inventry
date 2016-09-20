import Argo

extension Date: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Date> {
    switch json {
    case let .number(timestampInMilliseconds):
      let timestampInSeconds = Double(timestampInMilliseconds) / 1000
      return pure(Date(timeIntervalSince1970: timestampInSeconds))
    default:
      return .typeMismatch(expected: "Number", actual: json)
    }
  }
}
