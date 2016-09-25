import Delta
import Firebase

struct UpdateAuthUser: ActionType {
  let user: User?

  func reduce(state: AppState) -> AppState {
    state.user.value = user
    return state
  }
}
