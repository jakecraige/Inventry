import Firebase

struct Analytics {
  enum Events: String {
    case CreateProduct
    case CreateOrder
  }

  enum UserProperty: String {
    case NoneConfigured
  }

  enum Param: String {
    case HasBarcode
    case HasNotes
  }

  static func logEvent(event: Events, _ params: [String: NSObject]? = .None) {
    switch event {
    case .CreateOrder:
      FIRAnalytics.logEventWithName(kFIREventEcommercePurchase, parameters: params)
    default:
      FIRAnalytics.logEventWithName(event.rawValue, parameters: params)
    }
  }

  static func setUserProperty(property: UserProperty, value: String? = .None) {
    FIRAnalytics.setUserPropertyString(value, forName: property.rawValue)
  }
}
