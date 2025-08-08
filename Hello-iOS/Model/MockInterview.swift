
import Foundation

// MARK: 모의면접 세션 기록 (여러 질문 묶음)
struct MockInterviewGroup: Hashable {
  let id: String                        // 그룹 식별자
  let date: Date                      // 시행 날짜
  let records: [MockInterviewRecord]  // 해당 그룹에 속한 개별 답변
  
  // hashable 기준 id
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  // == 설정
  static func == (lhs: MockInterviewGroup, rhs: MockInterviewGroup) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: 모의면접 질문에 대한 개별 답변
struct MockInterviewRecord: Hashable {
  let id: Int                  // 답변 인덱스 (0 ~ 9)
  let groupId: String            // 소속된 그룹 ID
  let question: String         // 질문
  let modelAnswer: String      // 모범답안
  let myAnswer: String         // 내 답변
  let isSatisfied: Bool        // 만족 여부
  
  // hashable에 groupId까지 같이 추가
  func hash(into hasher: inout Hasher) {
    hasher.combine(groupId)
    hasher.combine(id)
  }
  static func == (l: Self, r: Self) -> Bool {
    l.groupId == r.groupId && l.id == r.id
  }
}
