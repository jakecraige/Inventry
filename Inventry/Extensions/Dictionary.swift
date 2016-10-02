import Foundation

// Workaround not being able to have a same type requirement on the dictionary `Key`
protocol _StringContaining {
  func contains(_ string: String) -> Bool
  var asString: String { get }
}
extension String: _StringContaining {
  var asString: String { return self }
}

extension Dictionary where Key: _StringContaining, Value: AnyObject {
  func select(keys: [String], partialMatching: Bool = true)
    -> [String: Value] {
    let keys = keys.map { $0.asString }.lazy
    return reduce([:]) { acc, keyValue in
      let (key, value) = (keyValue.0.asString, keyValue.1)
      
      if partialMatching {
        if keys.contains(where: { key.contains($0) }) {
          return acc + [key: value]
        }
      } else {
        if keys.contains(key) {
          return acc + [key: value]
        }
      }

      return acc
    }
  }

  func deepFlatten(keyPrefix: String = "") -> [String: AnyObject] {
    return reduce([:]) { acc, keyValue in
        let (key, value) = (keyValue.0.asString, keyValue.1)
        let newKey = [keyPrefix, key]
          .filter { !$0.isEmpty }
          .joined(separator: "/")

        if let value = value as? [String: AnyObject] {
            return acc + value.deepFlatten(keyPrefix: newKey)
        } else {
            return acc + [newKey: value]
        }
    }
  }
}
