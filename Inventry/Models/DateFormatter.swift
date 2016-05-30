import Foundation

struct DateFormatter {
  let date: NSDate

  init(_ date: NSDate) {
    self.date = date
  }

  var formatted: String {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter.stringFromDate(date)
  }
}
