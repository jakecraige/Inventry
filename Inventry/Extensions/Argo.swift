import Argo

func <|| <A where A: FIRNestedArray, A: Decodable, A == A.DecodedType>(json: JSON, key: String) -> Decoded<[A]> {
  return json <|| [key]
}

func <|| <A where A: FIRNestedArray, A: Decodable, A == A.DecodedType>(json: JSON, keys: [String]) -> Decoded<[A]> {
  return flatReduce(keys, initial: json, combine: decodedJSON) >>- Array<A>.decode
}

extension CollectionType where Generator.Element: FIRNestedArray, Generator.Element: Decodable, Generator.Element == Generator.Element.DecodedType {
  static func decode(j: JSON) -> Decoded<[Generator.Element]> {
    switch j {
    case let .Array(a):
      return sequence(a.map(Generator.Element.decode))
    case let .Object(o):
      return sequence(Array(o.keys).flatMap { o[$0].map(Generator.Element.decode) })
    default: return .typeMismatch("Array", actual: j)
    }
  }
}

func decodeFIRArray(json: JSON, key: String) -> Decoded<[String]> {
  return decodedJSON(json, forKey: key).flatMap { jsonForKey in
    return decodeFIRArray(jsonForKey)
  }
}

func decodeFIRArray(json: JSON) -> Decoded<[String]> {
  switch json {
  case let .Object(o): return pure(Array(o.keys))
  case .Bool: return pure([])
  default: return .typeMismatch("Object or Bool", actual: json)
  }
}
