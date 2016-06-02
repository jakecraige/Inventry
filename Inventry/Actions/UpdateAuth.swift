import Delta
import Firebase

struct UpdateAuth: ActionType {
  let user: FIRUser?

  func reduce(state: AppState) -> AppState {
    state.user.value = user
    return state
  }
}
