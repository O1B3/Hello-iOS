//
//  MockWordBook.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import Foundation

struct MockWordBook: Hashable {
  let category: String
  let id: Int
  let concepts: [MockConcept]
}

struct MockConcept: Hashable {
  let id: Int
  let categoryId: Int
  let concept: String
  let explain: String
  let latestUpdate: Date
  let isMemory: Bool
}
