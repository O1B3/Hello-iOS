import Testing
import Foundation
@testable import Hello_iOS


  
  @Test func testAttendance() {
    // 1. 도메인 모델 생성
    let id = UUID().uuidString
    let now = Date()
    let domain = Attendance(id: id, date: now, isAttendance: true)
    
    // 2. Realm 모델로 변환
    let realmObj = RealmAttendance(from: domain)
       
    // 3. Realm 모델 → 도메인 모델
    let mappedBack = realmObj.toDomain()
    
    // 4. 값 비교
    #expect(mappedBack.date.timeIntervalSince1970 == domain.date.timeIntervalSince1970)
    #expect(mappedBack.isAttendance == domain.isAttendance)
    #expect(mappedBack.id == domain.id)
  }
  

