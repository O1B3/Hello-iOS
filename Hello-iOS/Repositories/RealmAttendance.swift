
import Foundation

import RealmSwift


class RealmAttendance: Object {
  @Persisted var date: Date         // 출석한 날짜
  @Persisted var isAttendance: Bool // 출석 여부
  
  // 도메인 모델 → Realm 모델
  convenience init(from attendance: Attendance) {
    self.init()
    self.date = attendance.date
    self.isAttendance = attendance.isAttendance
  }
  
  // Realm 모델 → 도메인 모델
  func toDomain() -> Attendance {
    return Attendance(date: date, isAttendance: isAttendance)
  }
  
  // PK 설정
  override static func primaryKey() -> String? {
    return "date"
  }
}
