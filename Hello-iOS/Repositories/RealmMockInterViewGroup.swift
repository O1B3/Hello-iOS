
import Foundation

import RealmSwift

class RealmMockInterviewGroup: Object {
  @Persisted(primaryKey: true) var id: String             // 그룹 식별자
  @Persisted var date: Date                               // 날짜
  @Persisted var records: List<RealmMockInterviewRecord>  // 일대다 연결
  
  // 도메인 모델 → Realm 모델
  convenience init(from domain: MockInterviewGroup) {
    self.init()
    self.id = domain.id
    self.date = domain.date
    self.records.append(objectsIn: domain.records.map { RealmMockInterviewRecord(from: $0) })
  }
  
  // Realm 모델 → 도메인 모델
  func toDomain() -> MockInterviewGroup {
    MockInterviewGroup(
      id: id,
      date: date,
      records: records.map { $0.toDomain() }
    )
  }
}

