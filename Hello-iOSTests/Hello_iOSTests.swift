//
//  Hello_iOSTests.swift
//  Hello-iOSTests
//
//  Created by 이태윤 on 8/6/25.
//

import Testing
@testable import Hello_iOS
import Supabase
import Foundation


struct Hello_iOSTests {

  @Test func fetchLearningAllData() async throws {
    let repo = LearningRepository()
    let result = try await LearningService(learningRepository: repo).requestAllData()

    print(result)
  }

  @Test func fetchLearningRecentlyData() async throws {
    let repo = LearningRepository()
    let result = try await LearningService(learningRepository: repo).requestRecentlyData()

    print(result)
  }

  @Test func fetchLatestUpdateTime() async throws {
    let repo = LearningRepository()

    let result = try await repo.fetchLatestUpdateTime()

    print(result)
  }

  @Test func isUpdateNeeded() async throws {
    let repo = LearningRepository()
    let result = try await LearningService(learningRepository: repo).isUpdateNeeded()

    print(result)
  }
}
