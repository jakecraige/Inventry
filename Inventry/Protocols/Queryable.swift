import Firebase
import Argo

protocol Queryable {
  static var refName: String { get }
  static var ref: FIRDatabaseReference { get }

  static func save(obj: Self)
  static func observeArray(eventType eventType: FIRDataEventType, block: (([Self]) -> Void)) -> UInt
  static func observeArrayOnce(eventType eventType: FIRDataEventType, block: (([Self]) -> Void))
  static func observeObject(eventType eventType: FIRDataEventType, ref: FIRDatabaseReference, block: ((Self) -> Void)) -> UInt
  static func observeObjectOnce(eventType eventType: FIRDataEventType, block: ((Self) -> Void))

  var id: String? { get }
  var childRef: FIRDatabaseReference { get }
}

extension Queryable {
  static var refName: String {
    return "\(self)s"
  }

  static var ref: FIRDatabaseReference {
    return FIRDatabase.database().reference().child(refName)
  }

  var childRef: FIRDatabaseReference {
    if let id = id {
      return Self.ref.child(id)
    } else {
      return Self.ref.childByAutoId()
    }
  }
}

extension Queryable where Self: Encodable {
  static func save(obj: Self) {
    obj.childRef.setValue(obj.encode())
  }
}

// Self.DecodedType == Self required to call `decode` on Self.
extension Queryable where Self: Decodable, Self.DecodedType == Self {
  static func observeArray(eventType eventType: FIRDataEventType, block: (([Self]) -> Void)) -> UInt {
    return Self.ref.observeEventType(eventType, withBlock: { snapshot in
      block(convertSnapshot(snapshot))
    })
  }

  static func observeArrayOnce(eventType eventType: FIRDataEventType, block: (([Self]) -> Void)) {
    Self.ref.observeSingleEventOfType(eventType, withBlock: { snapshot in
      block(convertSnapshot(snapshot))
    })
  }

  static func observeObject(eventType eventType: FIRDataEventType, ref: FIRDatabaseReference = Self.ref, block: ((Self) -> Void)) -> UInt {
    return ref.observeEventType(eventType, withBlock: { snapshot in
      guard let value: Self = convertSnapshot(snapshot) else { return }
      block(value)
    })
  }

  static func observeObjectOnce(eventType eventType: FIRDataEventType, block: ((Self) -> Void)) {
    Self.ref.observeSingleEventOfType(eventType, withBlock: { snapshot in
      guard let value: Self = convertSnapshot(snapshot) else { return }
      block(value)
    })
  }

  private static func convertSnapshot(snapshot: FIRDataSnapshot) -> Self? {
    guard let object = decodeObject(snapshotToDictionary(snapshot)) else {
      return .None
    }

    return object
  }

  private static func convertSnapshot(snapshot: FIRDataSnapshot) -> [Self] {
    return snapshot.children
      .flatMap { $0 as? FIRDataSnapshot }
      .map(snapshotToDictionary)
      .flatMap(decodeObject)
  }

  // For some reason using `Argo.decode` doesn't work but this does...
  private static func decodeObject(dict: [String: AnyObject]) -> Self? {
    return self.decode(JSON(dict)).value
  }

  private static func snapshotToDictionary(snapshot: FIRDataSnapshot) -> [String: AnyObject] {
    guard var dict = snapshot.value as? [String: AnyObject] else { return [:] }
    dict["id"] = snapshot.key
    return dict
  }
}
