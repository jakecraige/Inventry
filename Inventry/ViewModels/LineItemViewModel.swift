struct LineItemViewModel {
  let lineItem: LineItem

  var name: String { return lineItem.name }
  var quantity: Int { return lineItem.quantity }

  var price: Cents {
    return lineItem.price * lineItem.quantity
  }

  var formattedPrice: String {
    let formatter = PriceFormatter(price, currency: lineItem.currency)
    return formatter.formatted
  }
}
