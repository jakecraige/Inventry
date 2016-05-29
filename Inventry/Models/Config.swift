import Firebase

struct Config {
  static let config = FIRRemoteConfig.remoteConfig()

  static var defaultTaxRate: Float {
    return config["default_tax_rate"].numberValue! as Float
  }
}
