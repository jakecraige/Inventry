/// Returns `item` after calling `update` to inspect and possibly
/// modify it.
///
/// If `T` is a value type, `update` uses an independent copy
/// of `item`. If `T` is a reference type, `update` uses the
/// same instance passed in, but it can substitute a different
/// instance by setting its parameter to a new value.
public func with<T>(item: T, @noescape update: ((inout T) throws -> Void)) rethrows -> T {
  var this = item
  try update(&this)
  return this
}

extension CollectionType {
  func find(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
    for item in self where try predicate(item) {
      return item
    }
    return .None
  }
}

/// Takes two dictionaries and produces a third, with all keys of the first and
/// second. Key collisions will favor the second dictionary.
func + <K,V>(left: [K:V], right: [K:V]) -> [K:V] {
  var dict = left

  for (k, v) in right {
    dict[k] = v
  }

  return dict
}

func not(value: Bool) -> Bool {
  return !value
}

func and(value1: Bool, value2: Bool) -> Bool {
  return value1 && value2
}
