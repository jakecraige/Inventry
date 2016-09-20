import Firebase

struct Analytics {
  // xxx rename these to match swift API
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

  static func logEvent(_ event: Events, _ params: [String: AnyObject]? = .none) {
    switch event {
    case .CreateOrder:
      FIRAnalytics.logEvent(withName: kFIREventEcommercePurchase, parameters: params as! [String : NSObject]?)
    default:
      FIRAnalytics.logEvent(withName: event.rawValue, parameters: params as! [String : NSObject]?)
    }
  }

  static func setUserProperty(_ property: UserProperty, value: String? = .none) {
    FIRAnalytics.setUserPropertyString(value, forName: property.rawValue)
  }
}
