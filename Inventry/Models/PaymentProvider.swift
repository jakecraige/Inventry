import Stripe
import PromiseKit

private let client = STPAPIClient.shared()

struct PaymentProvier {
  static func createToken(_ card: STPCardParams) -> Promise<String> {
    return Promise { resolve, reject in
      client.createToken(withCard: card) { token, error in
        if let error = error {
          reject(error)
        }
        if let token = token {
          resolve(token.tokenId)
        }
      }
    }
  }
}
