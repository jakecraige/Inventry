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

    let values = valuesForUpdate(model)
    ref.updateChildValues(values)

    return ref.key
  }

  static func save(
    dict: [String: AnyObject],
    ref: FIRDatabaseReference = FIRDatabase.database().reference()
  ) {
    ref.updateChildValues(dict)
  }

  static func valuesForUpdate<Model: Modelable where Model.DecodedType == Model>(
    model: Model,
    includeRootKey: Bool = false,
    rootKey: String = Model.refName
  ) -> [String: AnyObject]{
    var values = model.encode()

    if let tModel = model as? Timestampable {
      values["timestamps/updated_at"] = FIRServerValue.timestamp()
      if tModel.timestamps?.createdAt == .None {
        values["timestamps/created_at"] = FIRServerValue.timestamp()
      }
    }

    if includeRootKey {
      return values.reduce([:]) { acc, keyValue in
        let (key, value) = keyValue
        return acc + ["\(rootKey)/\(model.childRef.key)/\(key)": value]
      }
    } else {
      return values
    }
  }

  static func delete<Model: Modelable where Model.DecodedType == Model>(model: Model) {
    model.childRef.removeValue()
  }

  static func exists(ref: FIRDatabaseQuery) -> Observable<Bool> {
    return Observable.create { observer in
      let observerHandle = ref.observeEventType(
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
        ref.removeObserverWithHandle(observerHandle)
      }
    }
  }

  static func observeSnapshot(
    eventType: FIRDataEventType = .Value,
    ref: FIRDatabaseQuery
  ) -> Observable<FIRDataSnapshot> {
    return Observable.create { observer in
      let observerHandle = ref.observeEventType(
        eventType,
        withBlock: { observer.onNext($0) },
        withCancelBlock: { observer.onError($0) }
      )
      return AnonymousDisposable {
        ref.removeObserverWithHandle(observerHandle)
      }
    }
  }

  static func observe<T: Decodable where T == T.DecodedType>(
    eventType: FIRDataEventType = .Value,
    ref: FIRDatabaseQuery
  ) -> Observable<T> {
    return observeSnapshot(eventType, ref: ref).flatMap { snapshot -> Observable<T> in
      switch FIRDecode(snapshot) as Decoded<T> {
      case let .Success(model): return .just(model)
      case let .Failure(error): return .error(error)
      }
    }
  }

  static func observe<T: Decodable where T == T.DecodedType>(
    eventType: FIRDataEventType = .Value,
    ref: FIRDatabaseQuery
  ) -> Observable<[T]> {
    return observeSnapshot(eventType, ref: ref).map(FIRDecode)
  }

  // This is necessary to properly decode the object array format when requesting one structure
  // like: { "theID": true, "otherID": true }. The main thing is we need to call the decodeFIRArray
  // function since calling the default Argo decode will fail. I still haven't figured out how to
  // override it to handle decoding this case properly. It should probably also handle the case of
  // an array like: { 0: "1234", 1: "4567" }, but I haven't been using that structure yet.
  static func observe(
    eventType: FIRDataEventType = .Value,
    ref: FIRDatabaseQuery
  ) -> Observable<[String]> {
    return observeSnapshot(eventType, ref: ref).map { snapshot in
      guard let value = snapshot.value else { return [] }
      return decodeFIRArray(JSON(value)) ?? []
    }
  }

  // sugar for querying for multiple objects via an array of queries for individual ones
  static func observe<T: Decodable where T == T.DecodedType>(
    eventType: FIRDataEventType = .Value,
    refs: [FIRDatabaseQuery]
  ) -> Observable<[T]> {
    return refs
      .map { observe(eventType, ref: $0) }
      .combineLatest { $0 }
  }
}

// MARK: Private Methods
private extension Database {
  static func FIRDecode<T: Decodable where T == T.DecodedType>(snapshot: FIRDataSnapshot) -> [T] {
    return snapshot.children
      .flatMap { $0 as? FIRDataSnapshot }
      .flatMap { snapshot in
        // This guard is a hack because parsing a list of PublicUsers doesn't seem to work without it
        guard !snapshot.key.isEmpty else { return .None }
        return FIRDecode(snapshot)
      }
  }

  private static func FIRDecode<T: Decodable where T == T.DecodedType>(snapshot: FIRDataSnapshot) -> Decoded<T> {
    let decoded: Decoded<T> = decode(snapshot.asDictionary) <|> decode(snapshot.value ?? NSNull())
    if let error = decoded.error {
      print("---------------------------------------------------------------------")
      print("Decoding Error: Failed to decode type '\(String(T))'.")
      print("Snapshot was: \(snapshot)")
      print("Error was: \(error)")
      print("---------------------------------------------------------------------")
    }
    return decoded
  }

  private static func FIRDecode<T: Decodable where T == T.DecodedType>(snapshot: FIRDataSnapshot) -> T? {
    return FIRDecode(snapshot).value
  }
}
