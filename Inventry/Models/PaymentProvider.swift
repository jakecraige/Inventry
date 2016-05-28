import Stripe
import PromiseKit

private let client = STPAPIClient.sharedClient()

struct PaymentProvier {
  static func createToken(card: STPCardParams) -> Promise<String> {
    return Promise { resolve, reject in
      client.createTokenWithCard(card) { token, error in
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
