import Firebase
import Argo

struct Database<Model: Modelable where Model.DecodedType == Model> {
  static func save(model: Model) -> String {
    let ref = model.childRef
    ref.setValue(model.encode())
    return ref.key
  }

  static func delete(model: Model) {
    model.childRef.removeValue()
  }

  static func observeArray(eventType eventType: FIRDataEventType, ref: FIRDatabaseReference = Model.ref, block: (([Model]) -> Void)) -> UInt {
    return ref.observeEventType(eventType, withBlock: convertSnapshot(block))
  }

  static func observeObject(eventType eventType: FIRDataEventType, ref: FIRDatabaseReference = Model.ref, block: ((Model) -> Void)) -> UInt {
    return ref.observeEventType(eventType, withBlock: convertSnapshot(block))
  }

  static func observeArrayOnce(eventType eventType: FIRDataEventType, ref: FIRDatabaseReference = Model.ref, block: (([Model]) -> Void)) {
    ref.observeSingleEventOfType(eventType, withBlock: convertSnapshot(block))
  }

  static func observeObjectOnce(eventType eventType: FIRDataEventType, ref: FIRDatabaseReference = Model.ref, block: ((Model) -> Void)) {
    ref.observeSingleEventOfType(eventType, withBlock: convertSnapshot(block))
  }
}

// MARK: Private Methods
private extension Database {
  static func convertSnapshot(block: (([Model]) -> Void)) -> ((FIRDataSnapshot) -> Void) {
    return { snapshot in block(decodeChildren(snapshot)) }
  }

  static func convertSnapshot(block: ((Model) -> Void)) -> ((FIRDataSnapshot) -> Void) {
    return { snapshot in decode(snapshot.asDictionary).map(block) }
  }

  static func decodeChildren(snapshot: FIRDataSnapshot) -> [Model] {
    return snapshot.children
      .flatMap { ($0 as? FIRDataSnapshot)?.asDictionary }
      .flatMap(decode)
  }
}
