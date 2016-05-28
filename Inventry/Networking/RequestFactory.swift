import Swish

func baseRequest(url url: String, method: RequestMethod) -> NSMutableURLRequest {
  let url = NSURL(string: url)!
  let request = NSMutableURLRequest(URL: url)

  request.HTTPMethod = method.rawValue
  request.setValue("application/json", forHTTPHeaderField: "Accept")
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")

  return request
}
