//
//  Date+.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import Foundation

extension Date {
  /// date 타입을 timestamptz에 호환되는 문자열로 변형
  func dateToTimeStamptz() -> String {
    let formatter = ISO8601DateFormatter()

    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    return formatter.string(from: self)
  }
}
