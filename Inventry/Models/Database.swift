import Firebase
import Argo
import RxSwift

enum SortOrder {
  /// Ascending - order a..z, 1..9
  case asc
  /// Descending order z..a, 9..1
  case desc
}

struct Database<Model: Modelable where Model.DecodedType == Model> {
  static func save(model: Model) -> String {
    let ref = model.childRef
    var values = model.encode()

    if model is Timestampable {
      values["timestamps/updated_at"] = FIRServerValue.timestamp()
      if !model.isPersisted {
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

  static func observeArray(eventType eventType: FIRDataEventType, ref: FIRDatabaseQuery = Model.ref, orderBy: String? = .None, sort: SortOrder = .asc, block: (([Model]) -> Void)) -> UInt {
    if let orderBy = orderBy {
      return ref.queryOrderedByChild(orderBy).observeEventType(eventType, withBlock: convertSnapshot(block, sort: sort))
    } else {
      return ref.observeEventType(eventType, withBlock: convertSnapshot(block, sort: sort))
    }
  }

  static func observeObject(eventType eventType: FIRDataEventType, ref: FIRDatabaseQuery = Model.ref, block: ((Model) -> Void)) -> UInt {
    return ref.observeEventType(eventType, withBlock: convertSnapshot(block))
  }

  static func observeArrayOnce(eventType eventType: FIRDataEventType, ref: FIRDatabaseQuery = Model.ref, orderBy: String? = .None, sort: SortOrder = .asc, block: (([Model]) -> Void)) {
    if let orderBy = orderBy {
      return ref.queryOrderedByChild(orderBy).observeSingleEventOfType(eventType, withBlock: convertSnapshot(block, sort: sort))
    } else {
      return ref.observeSingleEventOfType(eventType, withBlock: convertSnapshot(block, sort: sort))
    }
  }

  static func observeObjectOnce(eventType eventType: FIRDataEventType, ref: FIRDatabaseQuery = Model.ref, block: ((Model) -> Void)) {
    ref.observeSingleEventOfType(eventType, withBlock: convertSnapshot(block))
  }
}

// MARK: Private Methods
private extension Database {
  static func convertSnapshot(block: (([Model]) -> Void), sort: SortOrder) -> ((FIRDataSnapshot) -> Void) {
    return { snapshot in
      let children = decodeChildren(snapshot)
      switch sort {
      case .asc: block(children) // Firebase default sort is asc
      case .desc: block(children.reverse())
      }
    }
  }

  static func convertSnapshot(block: ((Model) -> Void)) -> ((FIRDataSnapshot) -> Void) {
    return { snapshot in _ = decodeAndLogError(snapshot.asDictionary).map(block) }
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
