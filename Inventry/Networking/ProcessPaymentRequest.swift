import Swish

private let taskUrl = "https://webtask.it.auth0.com/api/run/wt-james_craige-gmail_com-0/process-payment?webtask_no_cache=1"

struct ProcessPaymentRequest: Request {
  typealias ResponseObject = Charge

  let amount: Cents
  let currency: Currency = .USD
  let description: String
  let token: String

  func build() -> NSURLRequest {
    let request = baseRequest(url: taskUrl, method: .POST)

    request.jsonPayload = [
      "amount": amount,
      "currency": currency.rawValue,
      "description": description,
      "token": token
    ]

    return request
  }
}
