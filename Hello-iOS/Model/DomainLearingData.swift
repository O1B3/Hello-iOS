
import Foundation

// MARK: –– 카테고리 모델
struct DomainCategories: Hashable {
  let id: Int
  let category: String
  let concepts: [DomainConcept]
  let latestUpdate: Date

  // hashable 기준 id
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  // == 설정
  static func == (lhs: DomainCategories, rhs: DomainCategories) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: –– 컨셉(개념) 모델
struct DomainConcept: Hashable {
  let id: Int
  let categoryId: Int
  let concept: String
  let explain: String
  let latestUpdate: Date
  var isMemory: Bool = false
  let qnas: [DomainQnA]
  
  // hashable 기준 id
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  // == 설정
  static func == (lhs: DomainConcept, rhs: DomainConcept) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: –– Q&A 모델
struct DomainQnA: Hashable {
  let id: Int
  let conceptId: Int
  let question: String
  let answer: String
  let latestUpdate: Date
  
  // hashable 기준 id
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  // == 설정
  static func == (lhs: DomainQnA, rhs: DomainQnA) -> Bool {
    return lhs.id == rhs.id
  }
}
