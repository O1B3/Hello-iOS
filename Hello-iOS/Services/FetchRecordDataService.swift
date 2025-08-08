
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
  func fetchinterViewGroups() -> [MockInterviewGroup] {
    return []
  }
  
  func fetchinterViewRecords(id: Int) -> [MockInterviewRecord] {
    return []
  }
}

