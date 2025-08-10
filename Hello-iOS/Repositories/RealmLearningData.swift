import Foundation
import RealmSwift

// MARK: - Category
final class RealmCategory: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var category: String
  @Persisted var concepts = List<RealmConcept>()
  @Persisted var latestUpdate: Date

  // 도메인 -> Realm (FK 주입)
  convenience init(from domain: DomainCategories) {
    self.init()
    id = domain.id
    category = domain.category
    latestUpdate = domain.latestUpdate
    let linked = domain.concepts.map { RealmConcept(from: $0) }
    concepts.append(objectsIn: linked)
  }

  // Realm -> 도메인 (FK 필터)
  func toDomain() -> DomainCategories {
    let filtered = concepts.filter { $0.categoryId == self.id }
    return DomainCategories(
      id: id,
      category: category,
      concepts: filtered.map { $0.toDomain() },
      latestUpdate: latestUpdate
    )
  }
}


// MARK: - Concept
final class RealmConcept: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var categoryId: Int
  @Persisted var concept: String
  @Persisted var explain: String
  @Persisted var latestUpdate: Date
  @Persisted var isMemory: Bool
  @Persisted var qnas = List<RealmQnA>()

  // 도메인 -> Realm (부모의 categoryId를 FK로 강제 주입)
  convenience init(from domain: DomainConcept) {
    self.init()
    id = domain.id
    self.categoryId = domain.categoryId
    concept = domain.concept
    explain = domain.explain
    latestUpdate = domain.latestUpdate
    isMemory = domain.isMemory

    // QnA에도 FK 주입 (conceptId = 이 Concept의 id)
    let linkedQnas = domain.qnas.map { RealmQnA(from: $0) }
    qnas.append(objectsIn: linkedQnas)
  }

  // Realm -> 도메인 (FK 필터)
  func toDomain() -> DomainConcept {
    let filteredQnas = qnas.filter { $0.conceptId == self.id }
    return DomainConcept(
      id: id,
      categoryId: categoryId,
      concept: concept,
      explain: explain,
      latestUpdate: latestUpdate,
      isMemory: isMemory,
      qnas: filteredQnas.map { $0.toDomain() }
    )
  }
}


// MARK: - QnA
final class RealmQnA: Object {
  @Persisted(primaryKey: true) var id: Int
  @Persisted var conceptId: Int
  @Persisted var question: String
  @Persisted var answer: String
  @Persisted var latestUpdate: Date

  // 도메인 -> Realm (FK 주입)
  convenience init(from domain: DomainQnA) {
    self.init()
    id = domain.id
    self.conceptId = domain.conceptId
    question = domain.question
    answer = domain.answer
    latestUpdate = domain.latestUpdate
  }

  // Realm -> 도메인
  func toDomain() -> DomainQnA {
    DomainQnA(
      id: id,
      conceptId: conceptId,
      question: question,
      answer: answer,
      latestUpdate: latestUpdate
    )
  }
}

