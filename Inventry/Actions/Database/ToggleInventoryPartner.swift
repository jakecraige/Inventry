import Delta
import Firebase
import RxSwift

struct ToggleInventoryPartner: DynamicActionType {
  let user: PublicUser
  let partner: PublicUser

  func call() -> Observable<PublicUser> {
    if user.inventorySharedWith.contains(partner.id!) {
      return removeSharingPartner()
    } else {
      return addSharingPartner()
    }
  }

  func removeSharingPartner() -> Observable<PublicUser> {
    var newUser = user
    var newPartner = partner
    newUser.inventorySharedWith = user.inventorySharedWith.filter { $0 != partner.id! }
    newPartner.inventorySharedFrom = partner.inventorySharedFrom.filter { $0 != user.id! }

    return Database.observeSave(values(partner: newPartner)).flatMapLatest {
      return Database.observeSave(newUser)
    }
  }

  func addSharingPartner() -> Observable<PublicUser> {
    var newUser = user
    var newPartner = partner
    newUser.inventorySharedWith.append(partner.id!)
    newPartner.inventorySharedFrom.append(user.id!)
    
    return Database.observeSave(newUser).flatMapLatest { _ in
      return Database.observeSave(self.values(partner: newPartner))
    }.map { newUser }
  }

  func values(partner: PublicUser) -> [String: AnyObject] {
    // We need to use valuesForUpdate here because we can only update a subset of the record
    // due to the security rules
    return Database.valuesForUpdate(
      partner,
      includeRootKey: true,
      selectKeys: ["inventorySharedFrom"]
    )
  }
}
