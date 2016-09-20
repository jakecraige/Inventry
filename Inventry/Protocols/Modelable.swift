import Firebase
import Argo

protocol Modelable: Decodable, Encodable, Equatable {
  static var refName: String { get }
  static var ref: FIRDatabaseReference { get }
  static func getChildRef(_ id: String) -> FIRDatabaseReference

  /// The key stored in Firebase. This is also used to tell if an object is persisted or not.
  var id: String? { get }
  var childRef: FIRDatabaseReference { get }
  var isPersisted: Bool { get }
}

extension Modelable {
  static var refName: String {
    return "\(self)s"
  }

  static var ref: FIRDatabaseReference {
    return FIRDatabase.database().reference().child(refName)
  }

  static func getChildRef(_ id: String) -> FIRDatabaseReference {
    return ref.child(id)
  }

  var childRef: FIRDatabaseReference {
    if let id = id {
      return Self.ref.child(id)
    } else {
      return Self.ref.childByAutoId()
    }
  }

  var isPersisted: Bool {
    return id != .none
  }
}

func == <Model: Modelable>(lhs: Model, rhs: Model) -> Bool {
  if let lhsId = lhs.id, let rhsId = rhs.id {
    return lhsId == rhsId
  } else {
    return false
  }
}
