import Delta
import Firebase
import RxSwift

struct ToggleInventoryPartner: DynamicActionType {
  let user: PublicUser
  let partner: PublicUser

  func call() -> Observable<PublicUser> {
    var newUser: PublicUser = user
    var newPartner: PublicUser = partner

    if user.inventorySharedWith.contains(partner.id!) {
      newUser.inventorySharedWith = user.inventorySharedWith.filter { $0 != partner.id! }
      newPartner.inventorySharedFrom = partner.inventorySharedFrom.filter { $0 != user.id! }
    } else {
      newUser.inventorySharedWith.append(partner.id!)
      newPartner.inventorySharedFrom.append(user.id!)
    }

    Database.save(
      Database.valuesForUpdate(newUser, includeRootKey: true) +
      Database.valuesForUpdate(newPartner, includeRootKey: true)
    )

    return .just(newUser)
  }
}
