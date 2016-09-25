extension NSError {
  static func inventry(message: String) -> NSError {
    return NSError(
      domain: (Bundle.main.bundleIdentifier ?? "unknown.domain"),
      code: 0,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
  }
}
