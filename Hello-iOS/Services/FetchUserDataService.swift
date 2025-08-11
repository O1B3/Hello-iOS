
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
  func fetchUserExp() -> UserExperience { UserExperience(exp: 11) }

  func fetchAttendance() -> [Attendance] {
    let cal = Calendar(identifier: .gregorian)
    let today = Date()
    let d = { (offset: Int, on: Bool) -> Attendance in
      Attendance(id: UUID().uuidString,
                 date: cal.date(byAdding: .day, value: offset, to: today)!,
                 isAttendance: on)
    }
    return [
      d(0,  true),  // 오늘 출석
      d(-1, true),  // 어제 출석
      d(-2, false), // 그제 결석
      d(-3, true),  // 3일전 출석
      d(-4, true),  // 3일전 출석
    ]
  }
}
