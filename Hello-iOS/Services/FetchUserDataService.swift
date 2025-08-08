
import Foundation
import RealmSwift

// 유저 데이터 획득 프로토콜
protocol FetchUserDataServiceProtocol {
  func fetchUserExp() -> UserExperience
  func fetchAttendance() -> [Attendance]
}

// 실제 Realm에서 데이터 가져오는 코드
struct FetchUserDataService: FetchUserDataServiceProtocol {
  let realm = try! Realm()
  
  func fetchUserExp() -> UserExperience {
    let realmUserStatus = realm.objects(RealmUserStatus.self).first ?? RealmUserStatus()
    let user = UserExperience(exp: realmUserStatus.exp)
    return user
  }
  
  func fetchAttendance() -> [Attendance] {
    let attendanceResults = realm.objects(RealmAttendance.self)
    return attendanceResults.map { $0.toDomain() }
  }
}

// Mock Data Testing Code
struct StubUserDataService: FetchUserDataServiceProtocol {
  func fetchUserExp() -> UserExperience {
    return UserExperience(exp: 11)
  }
  
  func fetchAttendance() -> [Attendance] {
    return [
      Attendance(id: UUID().uuidString, date: Date(), isAttendance: true)
    ]
  }
}
