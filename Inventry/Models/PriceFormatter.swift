import Foundation

struct PriceFormatter {
  let price: Cents
  let currency: Currency

  init(_ price: Cents, currency: Currency = .USD) {
    self.price = price
    self.currency = currency
  }

  init(_ product: Product) {
    self.price = product.price
    self.currency = product.currency
  }

  var dollarPrice: Float {
    return Float(price) / 100
  }

  var formatted: String {
    return formatter.stringFromNumber(dollarPrice)!
  }

  private var formatter: NSNumberFormatter {
    return with(NSNumberFormatter()) {
      $0.numberStyle = .CurrencyStyle
      $0.currencyCode = self.currency.rawValue
    }
  }
}
