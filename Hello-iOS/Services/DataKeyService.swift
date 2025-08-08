
import Foundation

// 날짜키 안전보장
enum DateKeyService {
  static let fmt: DateFormatter = {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "ko_KR")
    f.timeZone = TimeZone(secondsFromGMT: 9*3600) // Asia/Seoul
    f.dateFormat = "yyyy-MM-dd"
    return f
  }()
  static func makeKey(from date: Date) -> String { fmt.string(from: date) }
}
