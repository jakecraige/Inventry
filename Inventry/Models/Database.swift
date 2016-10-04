import Firebase
import Argo
import RxSwift
import Runes

/// Returned when a reference you try to subscribe to doesn't exist
struct NullRefError: Error {
  let message: String
  var debugDescription: String { return message }

  init(_ ref: FIRDatabaseQuery) {
    message = "Attempted to observer null reference for \(ref)"
  }
}

struct Database {
  static func observeSave<Model: Modelable>(_ model: Model) -> Observable<Model> where Model.DecodedType == Model  {
    let ref = model.childRef

    let values = valuesForUpdate(model)

    return Observable.create { observer in
      ref.updateChildValues(values) { error, _ in
        if let error = error {
          observer.onError(error)
        } else {
          var modelWithId = model
          modelWithId.id = ref.key
          observer.onNext(modelWithId)
          observer.onCompleted()
        }
      }

      return Disposables.create()
    }
  }

  static func save<Model: Modelable>(_ model: Model) -> String where Model.DecodedType == Model {
    let ref = model.childRef

    let values = valuesForUpdate(model)
    ref.updateChildValues(values)

    return ref.key
  }

  static func observeSave(
    _ dict: [AnyHashable: Any],
    ref: FIRDatabaseReference = FIRDatabase.database().reference()
  ) -> Observable<Void> {
    return Observable.create { observer in
      ref.updateChildValues(dict) { error, _ in
        if let error = error {
          observer.onError(error)
        } else {
          observer.onNext()
          observer.onCompleted()
        }
      }

      return Disposables.create()
    }
  }

  static func save(
    _ dict: [AnyHashable: Any],
    ref: FIRDatabaseReference = FIRDatabase.database().reference()
  ) {
    ref.updateChildValues(dict)
  }

  static func valuesForUpdate<Model: Modelable>(
    _ model: Model,
    includeRootKey: Bool = false,
    selectKeys: [String]? = .none,
    rootKey: String = Model.refName
  ) -> [String: AnyObject] where Model.DecodedType == Model{
    var values = model.encode()

    if let tModel = model as? Timestampable {
      values["timestamps/updated_at"] = FIRServerValue.timestamp() as AnyObject?
      if tModel.timestamps?.createdAt == .none {
        values["timestamps/created_at"] = FIRServerValue.timestamp() as AnyObject?
      }
    }

    if includeRootKey {
      values = values.reduce([:]) { acc, keyValue in
        let (key, value) = keyValue
        return acc + ["\(rootKey)/\(model.childRef.key)/\(key)": value]
      }
    }

    if let keysToSelect = selectKeys {
      return values.select(keys: keysToSelect, partialMatching: true)
    } else {
      return values
    }
  }

  static func delete<Model: Modelable>(_ model: Model) where Model.DecodedType == Model {
    model.childRef.removeValue()
  }

  static func exists(_ ref: FIRDatabaseQuery) -> Observable<Bool> {
    return Observable.create { observer in
      let observerHandle = ref.observe(
        .value,
        with: { snapshot in
          observer.onNext(snapshot.exists())
          observer.onCompleted()
        },
        withCancel: { error in
          observer.onError(error)
          observer.onCompleted()
        }
      )

      return Disposables.create {
        ref.removeObserver(withHandle: observerHandle)
      }
    }
  }

  static func observeSnapshot(
    _ eventType: FIRDataEventType = .value,
    ref: FIRDatabaseQuery
  ) -> Observable<FIRDataSnapshot> {
    return Observable.create { observer in
      let observerHandle = ref.observe(
        eventType,
        with: { observer.onNext($0) },
        withCancel: { observer.onError($0) }
      )
      return Disposables.create {
        ref.removeObserver(withHandle: observerHandle)
      }
    }
  }

  static func observe<T: Decodable>(
    _ eventType: FIRDataEventType = .value,
    ref: FIRDatabaseQuery
  ) -> Observable<T> where T == T.DecodedType {
    return observeSnapshot(eventType, ref: ref).flatMap { snapshot -> Observable<T> in
      switch FIRDecode(snapshot) as Decoded<T> {
      case let .success(model): return .just(model)
      case let .failure(error): return .error(error)
      }
    }
  }

  static func observe<Model: Modelable>(
    _ eventType: FIRDataEventType = .value,
    model: Model
  ) -> Observable<Model> where Model == Model.DecodedType {
    return observe(eventType, ref: model.childRef)
  }

  static func observe<T: Decodable>(
    _ eventType: FIRDataEventType = .value,
    ref: FIRDatabaseQuery
  ) -> Observable<[T]> where T == T.DecodedType {
    return observeSnapshot(eventType, ref: ref).map(FIRDecode)
  }

  // This is necessary to properly decode the object array format when requesting one structure
  // like: { "theID": true, "otherID": true }. The main thing is we need to call the decodeFIRArray
  // function since calling the default Argo decode will fail. I still haven't figured out how to
  // override it to handle decoding this case properly. It should probably also handle the case of
  // an array like: { 0: "1234", 1: "4567" }, but I haven't been using that structure yet.
  static func observe(
    _ eventType: FIRDataEventType = .value,
    ref: FIRDatabaseQuery
  ) -> Observable<[String]> {
    return observeSnapshot(eventType, ref: ref).map { snapshot in
      guard let value = snapshot.value else { return [] }
      return decodeFIRArray(json: JSON(value)) ?? []
    }
  }

  // sugar for querying for multiple objects via an array of queries for individual ones
  static func observe<T: Decodable>(
    _ eventType: FIRDataEventType = .value,
    refs: [FIRDatabaseQuery]
  ) -> Observable<[T]> where T == T.DecodedType {
    guard refs.count > 0 else { return .just([]) }
    return refs
      .map { observe(eventType, ref: $0) }
      .combineLatest { $0 }
  }
}

// MARK: Private Methods
private extension Database {
  static func FIRDecode<T: Decodable>(_ snapshot: FIRDataSnapshot) -> [T] where T == T.DecodedType {
    return snapshot.children
      .flatMap { $0 as? FIRDataSnapshot }
      .flatMap { snapshot in
        // This guard is a hack because parsing a list of PublicUsers doesn't seem to work without it
        guard !snapshot.key.isEmpty else { return .none }
        return FIRDecode(snapshot)
      }
  }

  static func FIRDecode<T: Decodable>(_ snapshot: FIRDataSnapshot) -> Decoded<T> where T == T.DecodedType {
    let decoded: Decoded<T> = decode(snapshot.asDictionary) <|> decode(snapshot.value ?? NSNull())
    if let error = decoded.error {
      print("---------------------------------------------------------------------")
      print("Decoding Error: Failed to decode type '\(String(describing: T.self))'.")
      print("Snapshot was: \(snapshot)")
      print("Error was: \(error)")
      print("---------------------------------------------------------------------")
    }
    return decoded
  }

  static func FIRDecode<T: Decodable>(_ snapshot: FIRDataSnapshot) -> T? where T == T.DecodedType {
    return FIRDecode(snapshot).value
  }
}
