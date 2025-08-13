
import Foundation

/// 앱 내에서 출석 UI 표시를 위한 데이터 모델
struct Attendance: Equatable, Hashable {
  let id: String
  let date: Date          // 출석한 날짜
  let isAttendance: Bool  // 출석 여부 (true = 출석함)
  
  init(id: String, date: Date, isAttendance: Bool = false) {
    self.id = id
    self.date = date
    self.isAttendance = isAttendance
  }
}
