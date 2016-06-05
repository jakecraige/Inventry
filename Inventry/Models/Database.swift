import Firebase
import Argo
import RxSwift

enum SortOrder {
  /// Ascending - order a..z, 1..9
  case asc
  /// Descending order z..a, 9..1
  case desc
}

/// Returned when a reference you try to subscribe to doesn't exist
struct NullRefError: ErrorType {
  let message: String
  var debugDescription: String { return message }

  init(_ ref: FIRDatabaseQuery) {
    message = "Attempted to observer null reference for \(ref)"
  }
}

struct Database<Model: Modelable where Model.DecodedType == Model> {
  static func save(model: Model) -> String {
    let ref = model.childRef
    var values = model.encode()

    if let tModel = model as? Timestampable {
      values["timestamps/updated_at"] = FIRServerValue.timestamp()
      if tModel.timestamps?.createdAt == .None {
        values["timestamps/created_at"] = FIRServerValue.timestamp()
      }
    }

    ref.updateChildValues(values)
    return ref.key
  }

  static func delete(model: Model) {
    model.childRef.removeValue()
  }

  static func exists(model: Model) -> Observable<Bool> {
    return Observable.create { observer in
      model.childRef.observeSingleEventOfType(
        .Value,
        withBlock: { snapshot in
          observer.onNext(snapshot.exists())
          observer.onCompleted()
        },
        withCancelBlock: { error in
          observer.onError(error)
          observer.onCompleted()
        }
      )
      return NopDisposable.instance
    }
  }

  static func find(
    eventType eventType: FIRDataEventType = .Value,
              ref: FIRDatabaseQuery = Model.ref,
              ids: [String]
    ) -> Observable<[Model]>
  {
    let queries = ids.map { id in observeObject(ref: Model.getChildRef(id)) }
    return queries.combineLatest { $0 }
  }

  static func allWhere(eventType eventType: FIRDataEventType = .Value, ref: FIRDatabaseQuery = Model.ref, key: String, value: AnyObject) -> Observable<[Model]> {
    let query = ref.queryOrderedByChild(key).queryStartingAtValue(value).queryEndingAtValue(value)
    return Observable.create { observer in
      let observerHandle = query.observeEventType(
        eventType,
        withBlock: { observer.onNext(decodeChildren($0)) },
        withCancelBlock: { observer.onError($0) }
      )

      return AnonymousDisposable {
        query.removeObserverWithHandle(observerHandle)
      }
    }
  }

  static func observeArray(eventType eventType: FIRDataEventType = .Value, ref: FIRDatabaseQuery = Model.ref, orderBy: String? = .None, sort: SortOrder = .asc) -> Observable<[Model]> {
    var query = ref
    return Observable.create { observer in
      if let orderBy = orderBy {
        query = ref.queryOrderedByChild(orderBy)
      }

      let observerHandle = query.observeEventType(
        eventType,
        withBlock: { observer.onNext(convertSnapshot($0, sort: sort)) },
        withCancelBlock: { observer.onError($0) }
      )
      return AnonymousDisposable {
        query.removeObserverWithHandle(observerHandle)
      }
    }
  }

  static func observeObject(eventType eventType: FIRDataEventType = .Value, ref: FIRDatabaseQuery = Model.ref) -> Observable<Model> {
    return Observable.create { observer in
      let observerHandle = ref.observeEventType(
        eventType,
        withBlock: { snapshot in
          if snapshot.exists() {
            _ = convertSnapshot(snapshot).map(observer.onNext)
          } else {
            print(NullRefError(ref))
          }
        },
        withCancelBlock: { observer.onError($0) }
      )
      return AnonymousDisposable {
        ref.removeObserverWithHandle(observerHandle)
      }
    }
  }

  static func observeArrayOnce(eventType eventType: FIRDataEventType = .Value, ref: FIRDatabaseQuery = Model.ref, orderBy: String? = .None, sort: SortOrder = .asc) -> Observable<[Model]> {
    var query = ref
    return Observable.create { observer in
      if let orderBy = orderBy {
        query = ref.queryOrderedByChild(orderBy)
      }

      query.observeSingleEventOfType(
        eventType,
        withBlock: { observer.onNext(convertSnapshot($0, sort: sort)) },
        withCancelBlock: { observer.onError($0) }
      )
      return NopDisposable.instance
    }
  }

  static func observeObjectOnce(eventType eventType: FIRDataEventType = .Value, ref: FIRDatabaseQuery = Model.ref) -> Observable<Model> {
    return Observable.create { observer in
      ref.observeSingleEventOfType(
        eventType,
        withBlock: { snapshot in
          if snapshot.exists() {
            _ = convertSnapshot(snapshot).map(observer.onNext)
          } else {
            print(NullRefError(ref))
          }
        },
        withCancelBlock: { observer.onError($0) }
      )
      return NopDisposable.instance
    }
  }
}

// MARK: Private Methods
private extension Database {
  static func convertSnapshot(snapshot: FIRDataSnapshot, sort: SortOrder) -> [Model] {
    let children = decodeChildren(snapshot)
    switch sort {
    case .asc: return children // Firebase default sort is asc
    case .desc: return children.reverse()
    }
  }

  static func convertSnapshot(snapshot: FIRDataSnapshot) -> Model? {
    guard snapshot.exists() else { return  .None }
    return decodeAndLogError(snapshot.asDictionary)
  }

  static func decodeChildren(snapshot: FIRDataSnapshot) -> [Model] {
    return snapshot.children
      .flatMap { ($0 as? FIRDataSnapshot)?.asDictionary }
      .flatMap(decodeAndLogError)
  }

  private static func decodeAndLogError(dict: [String: AnyObject]) -> Model? {
    switch decode(dict) as Decoded<Model> {
    case let .Success(obj):
      return obj
      
    case let .Failure(err):
      print("---------------------------------------------------------------------")
      print("Decoding Error: Failed to decode a model of type '\(String(Model))'.")
      print("Dictionary was: \(dict)")
      print("Error was: \(err)")
      print("---------------------------------------------------------------------")
      return .None
    }
  }
}
