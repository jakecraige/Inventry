import RxSwift

protocol Query {
  associatedtype ResponseType
  func build() -> Observable<ResponseType>
}

func sortByCreated<T: Timestampable>(_ models: [T]) -> [T] {
  return models.sorted { lhs, rhs in
    guard let lCreated = lhs.timestamps?.createdAt, let rCreated = rhs.timestamps?.createdAt
      else { return true }
    return lCreated.compare(rCreated as Date) == .orderedDescending
  }
}
