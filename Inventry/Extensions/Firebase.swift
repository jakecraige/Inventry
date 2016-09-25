import Firebase
import RxSwift

extension FIRDataSnapshot {
  var asDictionary: [String: AnyObject] {
    guard var dict = value as? [String: AnyObject] else { return [:] }
    dict["id"] = key as AnyObject?
    return dict
  }
}

extension Collection where Self.Iterator.Element == String {
  /// Used to encode an array of IDs into `{"id": true, "id2": true}`.
  func FIR_encode() -> [String: AnyObject] {
    if isEmpty {
      return [:]
    } else {
      return reduce([:]) { result, key in
        return result + [key: true as AnyObject]
      }
    }
  }
}

extension FIRUser {
  func getToken(forceRefresh: Bool) -> Observable<String> {
    return Observable.create { observer in
      self.getTokenForcingRefresh(forceRefresh) { token, error in
        if let error = error {
          observer.onError(error)
        } else {
          if let token = token {
            observer.onNext(token)
            observer.onCompleted()
          } else {
            observer.onError(NSError.inventry(message: "Token not defined and but expected it to be"))
          }
        }
      }
      return Disposables.create()
    }
  }
}
