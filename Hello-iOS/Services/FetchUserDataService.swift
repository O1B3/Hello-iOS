
import Foundation
import RealmSwift

protocol FetchUserDataServiceProtocol {
  func fetchUserExp() -> UserExperience
  func fetchAttendance() -> [Attendance]
}

struct FetchUserDataService: FetchUserDataServiceProtocol {
  // 실제 사용하는 코드
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

struct StubUserDataService: FetchUserDataServiceProtocol {
  //테스팅 코드
  func fetchUserExp() -> UserExperience {
    return UserExperience(exp: 11)
  }
  
  func fetchAttendance() -> [Attendance] {
    return [
      Attendance(id: UUID().uuidString, date: Date(), isAttendance: true)
    ]
  }
}
