
import Foundation
import RealmSwift

// 유저 데이터 획득 프로토콜
protocol RecordDataServiceProtocol {
  func fetchinterViewGroups() -> [MockInterviewGroup]        //   조회
  func deleteGroup(id: String) throws                        // 개별 삭제
  func deleteAll() throws                                   // 전체 삭제
}

// 실제 Realm에서 데이터 가져오는 코드
struct RealmRecordDataService: RecordDataServiceProtocol {
//  let realmService = RealmService()
//  DIContainer.shared.register { realmService as RealmServiceType }
//  let realm: RealmServiceType = DIContainer.shared.resolve()
  
  private let realm: Realm
  
  init(realm: Realm = try! Realm()) {
    self.realm = realm
  }
  
  func fetchinterViewGroups() -> [MockInterviewGroup] {
    let objects = realm.objects(RealmMockInterviewGroup.self)
      .sorted(byKeyPath: "date", ascending: false)
    // Realm -> Domain
    return objects.map { $0.toDomain() }
  }

  func deleteGroup(id: String) throws {
    guard let target = realm.object(ofType: RealmMockInterviewGroup.self, forPrimaryKey: id) else { return }
    try realm.write {
      realm.delete(target.records)
      realm.delete(target)
    }
  }
  
  func deleteAll() throws {
    let allGroups = realm.objects(RealmMockInterviewGroup.self)
    try realm.write {
      let allRecords = allGroups.flatMap { $0.records }
      realm.delete(allRecords)
      realm.delete(allGroups)
    }
  }
}

final class StubRecordDataService: RecordDataServiceProtocol {
  private var seed: [MockInterviewGroup]? = nil
  private var store: [MockInterviewGroup]
  
  init() {
    if let seed { self.store = seed }
    else {
        let recordA = MockInterviewRecord(
          id: 0,
          groupId: "group1",
          question: "Question 0",
          modelAnswer: "Answer 0",
          myAnswer: "My Answer",
          isSatisfied: true
        )
      
        let recordB = MockInterviewRecord(
          id: 1,
          groupId: "group1",
          question: "Question 1",
          modelAnswer: "Answer 1",
          myAnswer: "My Answer",
          isSatisfied: false
        )
      
        let recordC = MockInterviewRecord(
          id: 2,
          groupId: "group1",
          question: "Question 2",
          modelAnswer: "Answer 2",
          myAnswer: "My Answer",
          isSatisfied: true
        )
      
        let recordD = MockInterviewRecord(
          id: 0,
          groupId: "group2",
          question: "Question 0",
          modelAnswer: "Answer 0",
          myAnswer: "My Answer",
          isSatisfied: true
        )
      
        let recordE = MockInterviewRecord(
          id: 1,
          groupId: "group1",
          question: "Question 1",
          modelAnswer: "Answer 1",
          myAnswer: "My Answer",
          isSatisfied: false
        )
      
      
      self.store = [
        MockInterviewGroup(
          id: "group2",
          date: Date(),
          records: [recordD, recordE]
        ),
        MockInterviewGroup(
          id: "group1",
          date: Date().addingTimeInterval(-86400),
          records: [recordA, recordB, recordC]
        ),
      ]
    }
  }

  func fetchinterViewGroups() -> [MockInterviewGroup] {
    return store.sorted { $0.date > $1.date }
  }

  func deleteGroup(id: String) throws {
    store.removeAll { $0.id == id }
  }

  func deleteAll() throws {
    store.removeAll()
  }
}

