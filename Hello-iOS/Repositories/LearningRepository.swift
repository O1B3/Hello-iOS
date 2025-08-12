//
//  LearningRepository.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/6/25.
//

import Foundation

import Supabase

protocol LearningRepositoryProtocol {
  func fetchAllData() async throws -> [Categories]

  func fetchRectlyAllData(RectlyUpdateDate: Date) async throws -> [Categories]

  func fetchRectlyConcepts(RectlyUpdateDate: Date) async throws -> [Concept]

  func fetchLatestUpdateTime() async throws -> Date
}

class LearningRepository: LearningRepositoryProtocol {
  private let client: SupabaseClient

  init() {
    let apiKey = Bundle.main.infoDictionary?["SUPABASE_API_KEY"] as? String ?? ""
    let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""

    if apiKey.isEmpty || urlString.isEmpty {
      fatalError("⚠️ SUPABASE_API_KEY, SUPABASE_URL Config 설정 빠짐!!")
    }

    if let url = URL(string: "https://" + urlString) {
      client = SupabaseClient(supabaseURL: url, supabaseKey:apiKey)
    } else {
      fatalError("⚠️ URL 구성 오류")
    }
  }

  func fetchAllData() async throws -> [Categories] {
    var categories = [Categories]()

    categories = try await client
      .from("categories")
      .select("*, concepts(*, qnas(*))")
      .execute()
      .value

    return categories
  }

  func fetchRectlyAllData(RectlyUpdateDate: Date) async throws -> [Categories] {
    var categories = [Categories]()
    let dateString = RectlyUpdateDate.dateToTimeStamptz()

    // 반환되는 각 카테고리 내에서, concepts와 그 안의 qnas가 지정된 날짜 이후에 업데이트된 것만 포함하도록 필터링합니다.
    // 단, 하위 요소가 최신이고 상위 요소가 구형일 경우 요청되지 않습니다.
    // 하위 요소 시간 갱신시 연결된 상위 요소 또한 시간이 갱신되어야 합니다.
    categories = try await client
      .from("categories")
      .select("*, concepts(*, qnas(*))")
      .or("latest_update.gte.\(dateString)")
      .or("latest_update.gte.\(dateString)", referencedTable: "concepts")
      .or("latest_update.gte.\(dateString)", referencedTable: "concepts.qnas")
      .execute()
      .value

    return categories
  }

  func fetchRectlyConcepts(RectlyUpdateDate: Date) async throws -> [Concept] {
    var concepts = [Concept]()

    concepts = try await client
      .from("concepts")
      .select("*, qnas(*))")
      .gte("latest_update", value: RectlyUpdateDate.dateToTimeStamptz())
      .execute()
      .value

    return concepts
  }

  func fetchLatestUpdateTime() async throws -> Date {
    var date = [Date]()

    date = try await client
      .from("Recently_update_time")
      .select("*")
      .execute()
      .value

    return date.first ?? Date()
  }
}
