import RxSwift

protocol Query {
  associatedtype ResponseType
  func build() -> Observable<ResponseType>
}

func sortByCreated<T: Timestampable>(models: [T]) -> [T] {
  return models.sort { lhs, rhs in
    guard let lCreated = lhs.timestamps?.createdAt, rCreated = rhs.timestamps?.createdAt
      else { return true }
    return lCreated.compare(rCreated) == .OrderedDescending
  }
}
