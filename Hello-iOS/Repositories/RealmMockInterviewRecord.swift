
import Foundation

import RealmSwift

class RealmMockInterviewRecord: Object {
  @Persisted var id: Int              // 답변 인덱스
  @Persisted var groupId: String      // 그룹 UUID 문자열
  @Persisted var question: String     // 질문
  @Persisted var modelAnswer: String  // 모법 답안
  @Persisted var myAnswer: String     // 내 답변
  @Persisted var isSatisfied: Bool    // 만족 여부
  
  // 도메인 모델 → Realm 모델
  convenience init(from domain: MockInterviewRecord) {
    self.init()
    self.id = domain.id
    self.groupId = domain.groupId.uuidString
    self.question = domain.question
    self.modelAnswer = domain.modelAnswer
    self.myAnswer = domain.myAnswer
    self.isSatisfied = domain.isSatisfied
  }
  
  // Realm 모델 → 도메인 모델
  func toDomain() -> MockInterviewRecord {
    MockInterviewRecord(
      id: id,
      groupId: UUID(uuidString: groupId) ?? UUID(),
      question: question,
      modelAnswer: modelAnswer,
      myAnswer: myAnswer,
      isSatisfied: isSatisfied
    )
  }
}

