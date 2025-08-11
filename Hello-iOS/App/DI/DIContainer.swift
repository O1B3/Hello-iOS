//
//  DIContainer.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//
import Foundation

final class DIContainer {
  static let shared = DIContainer()

  private var services: [String: () -> Any] = [:]

  // 타입명과 객체를 생성하는 클로저를 딕셔너리에 등록
  func register<T>(_ service: @autoclosure @escaping () -> T) {
    let key = String(describing: T.self)
    services[key] = service
  }

  func register<T>(type: T.Type, _ service: @autoclosure @escaping () -> Any) {
    let key = String(describing: type)
    services[key] = service
  }

  // 저장된 클로저를 실행하여 새로운 객체를 생성하고 반환
  func resolve<T>() -> T {
    let key = String(describing: T.self)

    guard let serviceFactory = services[key], let service = serviceFactory() as? T else {
      fatalError("DIContainer error: \(key) is not registered")
    }

    return service
  }
}
