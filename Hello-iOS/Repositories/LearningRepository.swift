//
//  LearningRepository.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/6/25.
//

import Foundation

import Supabase

class LearningRepository {
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
}
