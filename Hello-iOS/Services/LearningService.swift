//
//  LearningService.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import Foundation

protocol LearningServiceProtocol {
  func requestAllData() async throws -> [Categories]

  func requestRecentlyData() async throws -> [Concept]

  func setLatestUpdateTimeNow()
}

class LearningService: LearningServiceProtocol {
  private let learningRepository: LearningRepository

  init(learningRepository: LearningRepository) {
    self.learningRepository = learningRepository
  }

  func requestAllData() async throws -> [Categories] {
    return try await learningRepository.fetchAllData()
  }

  func requestRecentlyData() async throws -> [Concept] {
    let date = UserDefaults.standard.object(forKey: "LatestUpdateTime") as! Date

    return try await learningRepository.fetchRectlyConcepts(RectlyUpdateDate: date)
  }

  func setLatestUpdateTimeNow() {
    UserDefaults.standard.set(Date(), forKey: "LatestUpdateTime")
  }
}
