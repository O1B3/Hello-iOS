
import Foundation
import RealmSwift

// 유저 데이터 획득 프로토콜
protocol FetchRecordDataServiceProtocol {
  func fetchinterViewGroups() -> [MockInterviewGroup]
  func fetchinterViewRecords(id: Int) -> [MockInterviewRecord]
}

// 실제 Realm에서 데이터 가져오는 코드
struct FetchRecordDataService: FetchRecordDataServiceProtocol {
  let realm = try! Realm()
  func fetchinterViewGroups() -> [MockInterviewGroup] {
    return []
  }
  func fetchinterViewRecords(id: Int) -> [MockInterviewRecord] {
    return []
  }
}

// Mock Data Testing Code
struct StubRecordDataService: FetchRecordDataServiceProtocol {
  
  let recordA = MockInterviewRecord(
    id: 0,
    groupId: "group1",
    question: "Q",
    modelAnswer: "A",
    myAnswer: "MA",
    isSatisfied: true
  )
  
  let recordB = MockInterviewRecord(
    id: 1,
    groupId: "group1",
    question: "Q",
    modelAnswer: "A",
    myAnswer: "MA",
    isSatisfied: false
  )
  
  let recordC = MockInterviewRecord(
    id: 2,
    groupId: "group1",
    question: "Q",
    modelAnswer: "A",
    myAnswer: "MA",
    isSatisfied: true
  )
  
  let recordD = MockInterviewRecord(
    id: 0,
    groupId: "group2",
    question: "Q",
    modelAnswer: "A",
    myAnswer: "MA",
    isSatisfied: true
  )
  
  let recordE = MockInterviewRecord(
    id: 1,
    groupId: "group1",
    question: "Q",
    modelAnswer: "A",
    myAnswer: "MA",
    isSatisfied: false
  )
  
  func fetchinterViewGroups() -> [MockInterviewGroup] {
    return [
      MockInterviewGroup(
        id: "group2",
        date: Date(),
        records: [recordD, recordE]
      ),
      MockInterviewGroup(
        id: "group1",
        date: Date().addingTimeInterval(-10000),
        records: [recordA, recordB, recordC]
      ),
    ]
  }
  
  func fetchinterViewRecords(id: Int) -> [MockInterviewRecord] {
    return [recordA, recordB, recordC]
  }
}

