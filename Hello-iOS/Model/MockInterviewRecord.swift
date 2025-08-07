
import Foundation

/// 모의면접 질문에 대한 개별 답변
struct MockInterviewRecord: Hashable {
  let id: Int                  // 답변 인덱스 (0 ~ 9)
  let groupId: String            // 소속된 그룹 ID
  let question: String         // 질문
  let modelAnswer: String      // 모범답안
  let myAnswer: String         // 내 답변
  let isSatisfied: Bool        // 만족 여부
}
