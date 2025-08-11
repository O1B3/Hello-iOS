
import Foundation
import RealmSwift

enum RealmServiceError: Error {
  case objectNotFound
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
  
  // MARK: - Create
  func insert<T: Object>(_ object: T) throws {
    try write { $0.add(object, update: .error) } // 중복 PK 존재 시 throw
  }
  
  func insert<T: Object>(_ objects: [T]) throws {
    try write { $0.add(objects, update: .error) } // 중복 PK 존재 시 throw
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
