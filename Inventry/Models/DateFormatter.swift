import Foundation

struct DateFormatter {
  let date: Date

  init(_ date: Date) {
    self.date = date
  }

  var formatted: String {
    let formatter = Foundation.DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
