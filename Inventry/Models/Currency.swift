import Argo

typealias Cents = Int

enum Currency: String {
  case USD
}

extension Currency: Decodable {
  static func decode(_ j: JSON) -> Decoded<Currency> {
    switch j {
    case let .string(s):
      return .fromOptional(Currency(rawValue: s.uppercased()))
    default: return .typeMismatch(expected: "Currency", actual: j)
    }
  }
}
