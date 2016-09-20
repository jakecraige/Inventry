import Swish
import PromiseKit
import RxSwift

extension APIClient {
  func performRequest<T: Request>(request: T) -> Promise<T.ResponseObject> {
    return Promise { resolve, reject in
      _ = self.performRequest(request) { response in
        switch response {
        case let .success(value): resolve(value)
        case let .failure(error): reject(error)
        }
      }
    }
  }

  // Return an observable that emits one a single event on success or error on failure
  func performRequest<T: Request>(request: T) -> Observable<T.ResponseObject> {
    return Observable.create { observable in
      let executingRequest = self.performRequest(request) { response in
        switch response {
        case let .success(value): observable.onNext(value)
        case let .failure(error): observable.onError(error)
        }
        observable.onCompleted()
      }

      return Disposables.create { executingRequest.cancel() }
    }.single()
  }
}
