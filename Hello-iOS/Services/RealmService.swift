// RealmService.swift
import Foundation
import RealmSwift

protocol RealmServiceType {
  // 트랜잭션
  func write(_ block: (Realm) throws -> Void) throws
  func writeAsync(_ block: @escaping (Realm) throws -> Void)

  // Upsert
  func upsert<T: Object>(_ object: T) throws
  func upsert<T: Object>(_ objects: [T]) throws

  // Read
  func fetch<T: Object>(_ type: T.Type,
                        predicate: NSPredicate?,
                        sorted: [RealmSwift.SortDescriptor]) throws -> Results<T>
  func find<T: Object>(_ type: T.Type, forPrimaryKey key: Any) throws -> T?

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
    do {
      try realm.write { try block(realm) }
    } catch {
      throw error
    }
  }

  func writeAsync(_ block: @escaping (Realm) throws -> Void) {
    bgQueue.async {
      autoreleasepool {
        do {
          let realm = try Realm(configuration: self.config)
          try realm.write { try block(realm) }
        } catch {
          // 필요하면 로깅/콜백
          #if DEBUG
          print("Realm writeAsync error:", error)
          #endif
        }
      }
    }
  }

  // MARK: - Upsert

  func upsert<T: Object>(_ object: T) throws {
    try write { $0.add(object, update: .modified) }
  }

  func upsert<T: Object>(_ objects: [T]) throws {
    try write { $0.add(objects, update: .modified) }
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
