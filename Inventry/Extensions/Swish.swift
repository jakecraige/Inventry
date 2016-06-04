import Swish
import PromiseKit
import RxSwift

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

  // Return an observable that emits one a single event on success or error on failure
  func performRequest<T: Request>(request: T) -> Observable<T.ResponseObject> {
    return Observable.create { observable in
      let executingRequest = self.performRequest(request) { response in
        switch response {
        case let .Success(value): observable.onNext(value)
        case let .Failure(error): observable.onError(error)
        }
        observable.onCompleted()
      }

      return AnonymousDisposable { executingRequest.cancel() }
    }.single()
  }
}
