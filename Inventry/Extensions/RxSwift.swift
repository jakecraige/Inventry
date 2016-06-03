import Delta
import RxSwift
import PromiseKit

extension Variable: ObservablePropertyType {
  public typealias ValueType = Element
}

extension Observable {
  func asPromise() -> Promise<Element> {
    return Promise { resolve, reject in
      var disposable: Disposable?
      disposable = self.subscribe(
        onNext: { value in
          resolve(value)
          disposable?.dispose()
        },
        onError: { error in
          reject(error)
          disposable?.dispose()
        }
      )
    }
  }
}
