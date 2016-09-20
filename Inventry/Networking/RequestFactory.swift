import Swish

func baseRequest(url: String, method: RequestMethod) -> URLRequest {
  let url = URL(string: url)!
  var request = URLRequest(url: url)

  request.httpMethod = method.rawValue
  request.setValue("application/json", forHTTPHeaderField: "Accept")
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")

  return request
}
