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
