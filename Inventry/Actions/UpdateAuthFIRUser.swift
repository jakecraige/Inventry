import Delta
import Firebase

struct UpdateAuthFIRUser: ActionType {
  let firUser: FIRUser?

  func reduce(state: AppState) -> AppState {
    state.firUser.value = firUser
    return state
  }
}
