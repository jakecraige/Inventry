struct LineItemViewModel {
  let lineItem: LineItem
  let product: Product

  var price: Cents {
    return product.price * lineItem.quantity
  }

  var formattedPrice: String {
    let formatter = PriceFormatter(price, currency: product.currency)
    return formatter.formatted
  }
}
