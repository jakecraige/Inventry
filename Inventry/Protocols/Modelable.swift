import Firebase
import Argo

protocol Modelable: Decodable, Encodable {
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
