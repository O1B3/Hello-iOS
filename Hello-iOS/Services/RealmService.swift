
import Foundation
import RealmSwift

// 테스트/호출부에서 분기하기 쉽도록 명시적 에러 타입 추가
enum RealmServiceError: Error, Equatable {
  case objectNotFound
  case duplicatePrimaryKey
  case missingPrimaryKeyValue
}

protocol RealmServiceType {
  // 트랜잭션
  func write(_ block: (Realm) throws -> Void) throws
  func writeAsync(_ block: @escaping (Realm) throws -> Void)
  
  // Create
  func insert<T: Object>(_ object: T) throws
  func insert<T: Object>(_ objects: [T]) throws
  
  // Read
  func fetch<T: Object>(_ type: T.Type,
                        predicate: NSPredicate?,
                        sorted: [RealmSwift.SortDescriptor]) throws -> Results<T>
  func find<T: Object>(_ type: T.Type, forPrimaryKey key: Any) throws -> T?
  
  // Update
  /// PK가 있는 타입을 PK로 찾아 업데이트
  func update<T: Object>(_ type: T.Type, forPrimaryKey key: Any, _ apply: (T) -> Void) throws
  /// PK가 없거나 일괄 수정이 필요할 때 predicate로 찾아 업데이트
  func updateAll<T: Object>(_ type: T.Type, predicate: NSPredicate, _ apply: (T) -> Void) throws
  
  // Delete
  func delete<T: Object>(_ object: T) throws
  func deleteAll<T: Object>(_ type: T.Type, predicate: NSPredicate?) throws
}

final class RealmService: RealmServiceType {
  private let config: Realm.Configuration
  private let bgQueue = DispatchQueue(label: "realm.bg.queue")
  
  init(config: Realm.Configuration = .defaultConfiguration) {
    self.config = config
  }
  
  // MARK: - Write
  func write(_ block: (Realm) throws -> Void) throws {
    let realm = try Realm(configuration: config)
    try realm.write { try block(realm) }
  }
  
  func writeAsync(_ block: @escaping (Realm) throws -> Void) {
    bgQueue.async {
      autoreleasepool {
        do {
          let realm = try Realm(configuration: self.config)
          try realm.write { try block(realm) }
        } catch {
#if DEBUG
          print("Realm writeAsync error:", error)
#endif
        }
      }
    }
  }
  
  // MARK: - Create (사전 중복 검사로 Obj-C 예외 방지)
  func insert<T: Object>(_ object: T) throws {
    let realm = try Realm(configuration: config)
    
    if let pkName = type(of: object).primaryKey() {
      guard let key = object.value(forKey: pkName) else {
        throw RealmServiceError.missingPrimaryKeyValue
      }
      if realm.object(ofType: T.self, forPrimaryKey: key) != nil {
        throw RealmServiceError.duplicatePrimaryKey
      }
    }
    try write { $0.add(object) } // 업서트(.modified/.error) 사용 금지
  }
  
  func insert<T: Object>(_ objects: [T]) throws {
    let realm = try Realm(configuration: config)
    
    if let pkName = T.primaryKey() {
      // 1) 동일 배치 내 중복 PK 검사
      var seen = Set<AnyHashable>()
      for o in objects {
        guard let key = o.value(forKey: pkName) as? AnyHashable else {
          throw RealmServiceError.missingPrimaryKeyValue
        }
        if !seen.insert(key).inserted {
          throw RealmServiceError.duplicatePrimaryKey
        }
      }
      // 2) DB 내 기존 중복 PK 검사
      for o in objects {
        let key = o.value(forKey: pkName)!
        if realm.object(ofType: T.self, forPrimaryKey: key) != nil {
          throw RealmServiceError.duplicatePrimaryKey
        }
      }
    }
    try write { $0.add(objects) }
  }
  
  // MARK: - Read
  func fetch<T: Object>(_ type: T.Type,
                        predicate: NSPredicate? = nil,
                        sorted: [RealmSwift.SortDescriptor] = []) throws -> Results<T> {
    let realm = try Realm(configuration: config)
    var results = realm.objects(type)
    if let predicate { results = results.filter(predicate) }
    if !sorted.isEmpty { results = results.sorted(by: sorted) }
    return results
  }
  
  func find<T: Object>(_ type: T.Type, forPrimaryKey key: Any) throws -> T? {
    let realm = try Realm(configuration: config)
    return realm.object(ofType: type, forPrimaryKey: key)
  }
  
  // MARK: - Update
  func update<T: Object>(_ type: T.Type, forPrimaryKey key: Any, _ apply: (T) -> Void) throws {
    let realm = try Realm(configuration: config)
    guard let obj = realm.object(ofType: type, forPrimaryKey: key) else {
      throw RealmServiceError.objectNotFound
    }
    try realm.write { apply(obj) }
  }
  
  func updateAll<T: Object>(_ type: T.Type, predicate: NSPredicate, _ apply: (T) -> Void) throws {
    let realm = try Realm(configuration: config)
    let targets = realm.objects(type).filter(predicate)
    guard !targets.isEmpty else { throw RealmServiceError.objectNotFound }
    try realm.write { targets.forEach(apply) }
  }
  
  // MARK: - Delete
  func delete<T: Object>(_ object: T) throws {
    try write { $0.delete(object) }
  }
  
  func deleteAll<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) throws {
    try write { realm in
      var targets = realm.objects(type)
      if let predicate { targets = targets.filter(predicate) }
      realm.delete(targets)
    }
  }
}

