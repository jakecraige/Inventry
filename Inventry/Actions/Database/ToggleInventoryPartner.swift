import Delta
import Firebase
import RxSwift

struct ToggleInventoryPartner: DynamicActionType {
  let user: PublicUser
  let partner: PublicUser

  func call() -> Observable<PublicUser> {
    var newUser = user
    var newPartner = partner

    if user.inventorySharedWith.contains(partner.id!) {
      newUser.inventorySharedWith = user.inventorySharedWith.filter { $0 != partner.id! }
      newPartner.inventorySharedFrom = partner.inventorySharedFrom.filter { $0 != user.id! }
    } else {
      newUser.inventorySharedWith.append(partner.id!)
      newPartner.inventorySharedFrom.append(user.id!)
    }

    return Database.observeSave(newUser)
      .flatMap { _ -> Observable<Void> in
        // We need to use valuesForUpdate here because we can only update a subset of the record
        // due to the security rules
        let values = Database.valuesForUpdate(
          newPartner,
          includeRootKey: true,
          selectKeys: ["inventorySharedFrom"]
        )
        return Database.observeSave(values)
      }.map {
        return newUser
      }
  }
}
