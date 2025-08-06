
import Foundation

import RealmSwift


class RealmAttendance: Object {
  @objc dynamic var date: Date = Date() // 출석한 날짜
  @objc dynamic var isAttendance: Bool = false // 출석여부
  
  // 도메인 모델 -> Realm모델
  convenience init(from attendance: Attendance) {
    self.init()
    self.date = attendance.date
    self.isAttendance = attendance.isAttendance
  }
  
  // Realm모델 -> 도메인 모델
  func toDomain() -> Attendance {
    return Attendance(date: date, isAttendance: isAttendance)
  }
  
  // PK 설정
  override static func primaryKey() -> String? {
      return "date"
  }

}

