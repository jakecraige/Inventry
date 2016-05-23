import Firebase
import Argo

protocol Queryable {
  static var refName: String { get }
  static var ref: FIRDatabaseReference { get }

  static func create(obj: Self)
  static func observeArray(eventType eventType: FIRDataEventType, block: (([Self]) -> Void))
  static func observeArrayOnce(eventType eventType: FIRDataEventType, block: (([Self]) -> Void))
  static func observeObject(eventType eventType: FIRDataEventType, block: ((Self) -> Void))
  static func observeObjectOnce(eventType eventType: FIRDataEventType, block: ((Self) -> Void))
}

extension Queryable {
  static var refName: String {
    return "\(self)s"
  }

  static var ref: FIRDatabaseReference {
    return FIRDatabase.database().reference().child(refName)
  }
}

extension Queryable where Self: Encodable {
  static func create(obj: Self) {
    ref.childByAutoId().setValue(obj.encode())
  }
}

// Self.DecodedType == Self required to call `decode` on Self.
extension Queryable where Self: Decodable, Self.DecodedType == Self {
  static func observeArray(eventType eventType: FIRDataEventType, block: (([Self]) -> Void)) {
    self.ref.observeEventType(eventType, withBlock: { snapshot in
      block(convertSnapshot(snapshot))
    })
  }

  static func observeArrayOnce(eventType eventType: FIRDataEventType, block: (([Self]) -> Void)) {
    self.ref.observeSingleEventOfType(eventType, withBlock: { snapshot in
      block(convertSnapshot(snapshot))
    })
  }

  static func observeObject(eventType eventType: FIRDataEventType, block: ((Self) -> Void)) {
    self.ref.observeEventType(eventType, withBlock: { snapshot in
      guard let value: Self = convertSnapshot(snapshot) else { return }
      block(value)
    })
  }

  static func observeObjectOnce(eventType eventType: FIRDataEventType, block: ((Self) -> Void)) {
    self.ref.observeSingleEventOfType(eventType, withBlock: { snapshot in
      guard let value: Self = convertSnapshot(snapshot) else { return }
      block(value)
    })
  }

  private static func convertSnapshot(snapshot: FIRDataSnapshot) -> Self? {
    guard let value = snapshot.value, let object = self.decodeObject(value) else {
      return .None
    }

    return object
  }

  private static func convertSnapshot(snapshot: FIRDataSnapshot) -> [Self] {
    return snapshot.children
      .flatMap({ ($0 as? FIRDataSnapshot)?.value })
      .flatMap(self.decodeObject)
  }

  // For some reason using `Argo.decode` doesn't work but this does...
  private static func decodeObject(snapshotValue: AnyObject) -> Self? {
    return self.decode(JSON(snapshotValue)).value
  }
}
