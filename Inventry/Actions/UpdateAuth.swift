import Delta
import Firebase

struct UpdateAuth: ActionType {
  let firUser: FIRUser?
  let user: User?

  init(firUser: FIRUser? = .none, user: User? = .none) {
    self.firUser = firUser
    self.user = user
  }

  func reduce(state: AppState) -> AppState {
    if let firUser = firUser {
      state.firUser.value = firUser
    }
    if let user = user {
      state.user.value = user
    }

    return state
  }
}
