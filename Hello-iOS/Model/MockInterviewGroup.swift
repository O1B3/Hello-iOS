
import Foundation

/// 모의면접 세션 기록 (여러 질문 묶음)
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
