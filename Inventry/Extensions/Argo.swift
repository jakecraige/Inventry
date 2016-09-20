import Argo
import Runes

func <|| <A>(json: JSON, key: String) -> Decoded<[A]> where A: FIRNestedArray, A: Decodable, A == A.DecodedType {
  return json <|| [key]
}

func <|| <A>(json: JSON, keys: [String]) -> Decoded<[A]> where A: FIRNestedArray, A: Decodable, A == A.DecodedType {
  return flatReduce(keys, initial: json, combine: decodedJSON) >>- Array<A>.decode
}

extension Collection where Iterator.Element: FIRNestedArray, Iterator.Element: Decodable, Iterator.Element == Iterator.Element.DecodedType {
  static func decode(_ j: JSON) -> Decoded<[Iterator.Element]> {
    switch j {
    case let .array(a):
      return sequence(a.map(Generator.Element.decode))
    case let .object(o):
      return sequence(Array(o.keys).flatMap { o[$0].map(Generator.Element.decode) })
    default: return .typeMismatch(expected: "Array", actual: j)
    }
  }
}

func decodeFIRArray(json: JSON, key: String) -> Decoded<[String]> {
  return decodedJSON(json, forKey: key).flatMap { jsonForKey in
    return decodeFIRArray(json: jsonForKey)
  }
}

func decodeFIRArray(json: JSON) -> Decoded<[String]> {
  switch json {
  case let .object(o): return pure(Array(o.keys))
  case .bool: return pure([])
  default: return .typeMismatch(expected: "Object or Bool", actual: json)
  }
}
