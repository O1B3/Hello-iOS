//
//  LearningService.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import Foundation

protocol LearningServiceProtocol {
  func requestAllData() async throws -> [Categories]

  func requestRecentlyData() async throws -> [Categories]

  func setLatestUpdateTimeNow()
}

class LearningService: LearningServiceProtocol {
  private let learningRepository: LearningRepositoryProtocol

  init(learningRepository: LearningRepositoryProtocol) {
    self.learningRepository = learningRepository
  }

  func requestAllData() async throws -> [Categories] {
    return try await learningRepository.fetchAllData()
  }

  func requestRecentlyData() async throws -> [Categories] {
    let date = requestLatestUpdateTime()
    do {
        return try await learningRepository.fetchRectlyAllData(RectlyUpdateDate: date)
    } catch {
        // Handle or rethrow the error
        print("Error fetching recent data: \(error)")
        throw error
    }
  }

  func setLatestUpdateTimeNow() {
    UserDefaults.standard.set(Date(), forKey: "LatestUpdateTime")
  }

  func isUpdateNeeded() async throws -> Bool {
    let dblatestUpdateTime = try await learningRepository.fetchLatestUpdateTime()
    let latestUpdateTime = requestLatestUpdateTime()

    return dblatestUpdateTime > latestUpdateTime
  }

  private func requestLatestUpdateTime() -> Date {
    if let date = UserDefaults.standard.object(forKey: "LatestUpdateTime") as? Date {
        return date
    } else {
        UserDefaults.standard.set(Date.distantPast, forKey: "LatestUpdateTime")
        return Date.distantPast
    }
  }
}
