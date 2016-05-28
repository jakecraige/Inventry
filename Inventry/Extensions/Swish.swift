import Swish
import PromiseKit

extension APIClient {
  func performRequest<T: Request>(request: T) -> Promise<T.ResponseObject> {
    return Promise { resolve, reject in
      self.performRequest(request) { response in
        switch response {
        case let .Success(value): resolve(value)
        case let .Failure(error): reject(error)
        }
      }
    }
  }
}
