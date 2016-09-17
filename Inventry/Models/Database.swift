import Firebase
import Argo
import RxSwift

/// Returned when a reference you try to subscribe to doesn't exist
struct NullRefError: ErrorType {
  let message: String
  var debugDescription: String { return message }

  init(_ ref: FIRDatabaseQuery) {
    message = "Attempted to observer null reference for \(ref)"
  }
}

struct Database {
  static func save<Model: Modelable where Model.DecodedType == Model>(model: Model) -> String {
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

  static func delete<Model: Modelable where Model.DecodedType == Model>(model: Model) {
    model.childRef.removeValue()
  }

  static func exists(query: FIRDatabaseQuery) -> Observable<Bool> {
    return Observable.create { observer in
      let observerHandle = query.observeEventType(
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

      return AnonymousDisposable {
        query.removeObserverWithHandle(observerHandle)
      }
    }
  }

  static func observe(
    eventType: FIRDataEventType = .Value,
    query: FIRDatabaseQuery
  ) -> Observable<FIRDataSnapshot> {
    return Observable.create { observer in
      let observerHandle = query.observeEventType(
        eventType,
        withBlock: { observer.onNext($0) },
        withCancelBlock: { observer.onError($0) }
      )
      return AnonymousDisposable {
        query.removeObserverWithHandle(observerHandle)
      }
    }
  }

  // sugar for querying for multiple objects via an array of queries for individual ones
  static func observe<Model: Modelable where Model.DecodedType == Model>(
    eventType: FIRDataEventType = .Value,
    queries: [FIRDatabaseQuery]
  ) -> Observable<[Model]> {
    return queries
      .map { observe(eventType, query: $0) }
      .combineLatest { $0 }
  }

  static func observe<Model: Modelable where Model.DecodedType == Model>(
    eventType: FIRDataEventType = .Value,
    query: FIRDatabaseQuery = Model.ref
  ) -> Observable<[Model]> {
    return observe(eventType, query: query).map(decodeChildren)
  }

  static func observe<Model: Modelable where Model.DecodedType == Model>(
    eventType: FIRDataEventType = .Value,
    query: FIRDatabaseQuery = Model.ref
  ) -> Observable<Model> {
    return observe(eventType, query: query).flatMap { snapshot -> Observable<Model> in
      let decoded: Decoded<Model> = decodeObject(snapshot)
      switch decoded {
      case let .Success(model): return .just(model)
      case let .Failure(error): return .error(error)
      }
    }
  }
}

// MARK: Private Methods
private extension Database {
  static func decodeObject<Model: Modelable where Model.DecodedType == Model>(snapshot: FIRDataSnapshot) -> Decoded<Model> {
    return decodeAndLogError(snapshot.asDictionary)
  }

  static func decodeChildren<Model: Modelable where Model.DecodedType == Model>(snapshot: FIRDataSnapshot) -> [Model] {
    return snapshot.children
      .flatMap { ($0 as? FIRDataSnapshot)?.asDictionary }
      .flatMap(decodeAndLogError)
  }

  private static func decodeAndLogError<Model: Modelable where Model.DecodedType == Model>(dict: [String: AnyObject]) -> Decoded<Model> {
    let decoded: Decoded<Model> = decode(dict)
    if let error = decoded.error {
      print("---------------------------------------------------------------------")
      print("Decoding Error: Failed to decode a model of type '\(String(Model))'.")
      print("Dictionary was: \(dict)")
      print("Error was: \(error)")
      print("---------------------------------------------------------------------")
    }
    return decoded
  }

  private static func decodeAndLogError<Model: Modelable where Model.DecodedType == Model>(dict: [String: AnyObject]) -> Model? {
    return decodeAndLogError(dict).value
  }
}
