
import Foundation

import RealmSwift


class RealmAttendance: Object {
  @Persisted var id: String         // uuid
  @Persisted var date: Date         // 출석한 날짜
  @Persisted var isAttendance: Bool // 출석 여부
  
  // 도메인 모델 → Realm 모델
  convenience init(from domain: Attendance) {
    self.init()
    self.id = domain.id
    self.date = domain.date
    self.isAttendance = domain.isAttendance
  }
  
  // Realm 모델 → 도메인 모델
  func toDomain() -> Attendance {
    Attendance(id: id, date: date, isAttendance: isAttendance)
  }
  
  // PK 설정
  override static func primaryKey() -> String? {
    return "id"
  }
}
