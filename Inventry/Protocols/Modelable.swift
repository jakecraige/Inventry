import Firebase
import Argo

protocol Modelable: Decodable, Encodable, Equatable {
  static var refName: String { get }
  static var ref: FIRDatabaseReference { get }

  var id: String? { get }
  var childRef: FIRDatabaseReference { get }
}

extension Modelable {
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

func == <Model: Modelable>(lhs: Model, rhs: Model) -> Bool {
  if let lhsId = lhs.id, let rhsId = rhs.id {
    return lhsId == rhsId
  } else {
    return false
  }
}
