import Argo

typealias Cents = Int

enum Currency: String {
  case USD
}

extension Currency: Decodable {
  static func decode(j: JSON) -> Decoded<Currency> {
    switch j {
    case let .String(s):
      return .fromOptional(Currency(rawValue: s.uppercaseString))
    default: return .typeMismatch("Currency", actual: j)
    }
  }
}
