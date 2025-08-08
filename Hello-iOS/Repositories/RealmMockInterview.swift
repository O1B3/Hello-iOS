
import Foundation

import RealmSwift

// MARK: 모의면접 세션 기록 (여러 질문 묶음) Realm DB
class RealmMockInterviewGroup: Object {
  @Persisted(primaryKey: true) var id: String             // 그룹 식별자
  @Persisted var date: Date                               // 날짜
  @Persisted var records: List<RealmMockInterviewRecord>  // 레코드
  
  // 도메인 모델 → Realm 모델
  convenience init(from domain: MockInterviewGroup) {
    self.init()
    self.id = domain.id
    self.date = domain.date
    // 생성 시에 groupId 주입
    let linkedRecords = domain.records.map { RealmMockInterviewRecord(from: $0, groupId: domain.id) }
    self.records.append(objectsIn: linkedRecords)
  }
  
  // Realm 모델 → 도메인 모델
  func toDomain() -> MockInterviewGroup {
      let filtered = records.filter { $0.groupId == self.id } // groupId 일치 필터링
      return MockInterviewGroup(
        id: id,
        date: date,
        records: filtered.map { $0.toDomain() }
      )
    }
}

// MARK: 모의면접 질문에 대한 개별 답변
class RealmMockInterviewRecord: Object {
  @Persisted var id: Int              // 답변 인덱스
  @Persisted var groupId: String      // 그룹 UUID 문자열
  @Persisted var question: String     // 질문
  @Persisted var modelAnswer: String  // 모법 답안
  @Persisted var myAnswer: String     // 내 답변
  @Persisted var isSatisfied: Bool    // 만족 여부
  
  // 도메인 모델 → Realm 모델
  convenience init(from domain: MockInterviewRecord, groupId: String) {
    self.init()
    self.id = domain.id
    self.groupId = groupId
    self.question = domain.question
    self.modelAnswer = domain.modelAnswer
    self.myAnswer = domain.myAnswer
    self.isSatisfied = domain.isSatisfied
  }
  
  // Realm 모델 → 도메인 모델
  func toDomain() -> MockInterviewRecord {
    MockInterviewRecord(
      id: id,
      groupId: groupId,
      question: question,
      modelAnswer: modelAnswer,
      myAnswer: myAnswer,
      isSatisfied: isSatisfied
    )
  }
}
