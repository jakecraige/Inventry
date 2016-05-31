import Firebase

struct Config {
  static let config = FIRRemoteConfig.remoteConfig()

  static var defaultTaxRate: Float {
    return config["default_tax_rate"].numberValue! as Float
  }

  static var defaultShippingRate: Float {
    return config["default_shipping_rate"].numberValue! as Float
  }
}
