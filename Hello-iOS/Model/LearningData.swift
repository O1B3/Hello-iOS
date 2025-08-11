//
//  LearningData.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/6/25.
//

import Foundation

// MARK: –– 카테고리 모델
public struct Categories: Codable {
  public let id: Int
  public let category: String
  public let concepts: [Concept]?   // 중첩 조회 시에만 포함
  public let latestUpdate: Date

  enum CodingKeys: String, CodingKey {
    case id
    case category
    case concepts
    case latestUpdate = "latest_update"
  }
}

// MARK: –– 컨셉(개념) 모델
public struct Concept: Codable {
  public let id: Int
  public let categoryId: Int        // FK: categories.id
  public let concept: String
  public let explain: String
  public let latestUpdate: Date

  public let qnas: [QnA]?           // 중첩 조회 시에만 포함

  // JSON Key 매핑 (snake_case → camelCase)
  enum CodingKeys: String, CodingKey {
    case id
    case categoryId = "category_id"
    case concept
    case explain
    case qnas
    case latestUpdate = "latest_update"
  }
}

// MARK: –– Q&A 모델
public struct QnA: Codable {
  public let id: Int
  public let conceptId: Int         // FK: concepts.id
  public let question: String
  public let answer: String
  public let latestUpdate: Date

  enum CodingKeys: String, CodingKey {
    case id
    case conceptId = "concept_id"
    case question
    case answer
    case latestUpdate = "latest_update"
  }
}

// MARK: - Mappers to Domain
extension Categories {
    func toDomain() -> DomainCategories {
        return DomainCategories(
            id: self.id,
            category: self.category,
            concepts: self.concepts?.map { $0.toDomain() } ?? [],
            latestUpdate: self.latestUpdate
        )
    }
}

extension Concept {
    func toDomain() -> DomainConcept {
        return DomainConcept(
            id: self.id,
            categoryId: self.categoryId,
            concept: self.concept,
            explain: self.explain,
            latestUpdate: self.latestUpdate,
            isMemory: false, // 기본값 설정, 필요시 로직 추가
            qnas: self.qnas?.map { $0.toDomain() } ?? []
        )
    }
}

extension QnA {
    func toDomain() -> DomainQnA {
        return DomainQnA(
            id: self.id,
            conceptId: self.conceptId,
            question: self.question,
            answer: self.answer,
            latestUpdate: self.latestUpdate
        )
    }
}
