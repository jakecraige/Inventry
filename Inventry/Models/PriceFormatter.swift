import Foundation

struct PriceFormatter {
  let price: Cents
  let currency: Currency
  let formatter: NumberFormatter

  init(_ price: Cents, currency: Currency = .USD) {
    self.price = price
    self.currency = currency
    self.formatter = createFormatter(forCurrency: currency)
  }

  init(_ product: Product) {
    self.price = product.price
    self.currency = product.currency
    self.formatter = createFormatter(forCurrency: currency)
  }

  init?(_ order: Order) {
    if let charge = order.charge {
      self.price = charge.amount
      self.currency = charge.currency
      self.formatter = createFormatter(forCurrency: charge.currency)
    } else {
      return nil
    }
  }

  var dollarPrice: Float {
    return Float(price) / 100
  }

  var formatted: String {
    return formatter.string(from: NSNumber(value: dollarPrice))!
  }
}

private func createFormatter(forCurrency currency: Currency) -> NumberFormatter {
  let formatter = NumberFormatter()
  formatter.numberStyle = .currency
  formatter.currencyCode = currency.rawValue
  return formatter
}
