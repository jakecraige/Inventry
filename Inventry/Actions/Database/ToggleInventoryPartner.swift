import Delta
import Firebase
import RxSwift

struct ToggleInventoryPartner: DynamicActionType {
  let user: PublicUser
  let partner: PublicUser

  func call() -> Observable<PublicUser> {
    let newUser: PublicUser
    let newPartner: PublicUser

    if user.inventorySharedWith.contains(partner.id!) {
      newUser = with(user) { $0.inventorySharedWith = $0.inventorySharedWith.filter { $0 != partner.id! } }
      newPartner = with(partner) { $0.inventorySharedFrom = $0.inventorySharedFrom.filter { $0 != user.id! } }
    } else {
      newUser = with(user) { $0.inventorySharedWith.append(partner.id!) }
      newPartner = with(partner) { $0.inventorySharedFrom.append(user.id!) }
    }

    Database.save(
      Database.valuesForUpdate(newUser, includeRootKey: true) +
      Database.valuesForUpdate(newPartner, includeRootKey: true)
    )

    return .just(newUser)
  }
}
