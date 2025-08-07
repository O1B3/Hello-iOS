
import Foundation
import Testing

@testable import Hello_iOS

// Attendance 모델 테스트
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

// MockInterviewRecord 모델 테스트
@Test func testMockInterviewRecord() {
  let domain = MockInterviewRecord(id: 0, groupId: "g123", question: "Q?", modelAnswer: "A", myAnswer: "MyA", isSatisfied: true)
  let realmObj = RealmMockInterviewRecord(from: domain)
  let mappedBack = realmObj.toDomain()
  #expect(mappedBack == domain)
}

// MockInterviewGroup 모델 테스트
@Test func testMockInterviewGroup() {
  // 1. 개별 답변 모델 생성
  let record1 = MockInterviewRecord(
    id: 0,
    groupId: "test-group-id",
    question: "Q1?",
    modelAnswer: "A1",
    myAnswer: "MyA1",
    isSatisfied: true
  )
  let record2 = MockInterviewRecord(
    id: 1,
    groupId: "test-group-id",
    question: "Q2?",
    modelAnswer: "A2",
    myAnswer: "MyA2",
    isSatisfied: false
  )
  
  // 2. 그룹(도메인) 생성
  let groupId = UUID().uuidString
  let now = Date()
  let domain = MockInterviewGroup(id: groupId, date: now, records: [record1, record2])
  
  // 3. Realm 모델로 변환
  let realmObj = RealmMockInterviewGroup(from: domain)
  
  // 4. Realm → 도메인
  let mappedBack = realmObj.toDomain()
  
  // 5. 값 비교
  #expect(mappedBack.id == domain.id)
  #expect(mappedBack.date.timeIntervalSince1970 == domain.date.timeIntervalSince1970)
  #expect(mappedBack.records.count == domain.records.count)
  // 각 record 값도 동일한지 확인
  for (a, b) in zip(mappedBack.records, domain.records) {
    #expect(a.id == b.id)
    #expect(a.groupId == b.groupId)
    #expect(a.question == b.question)
    #expect(a.modelAnswer == b.modelAnswer)
    #expect(a.myAnswer == b.myAnswer)
    #expect(a.isSatisfied == b.isSatisfied)
  }
}

// UserExperience과 레벨 패턴 매칭 테스트
@Test func testUserExperience_and_LevelPatternMatching() {
  // 1. 다양한 경험치 값과 기대 레벨 케이스 정의
  let testCases: [(exp: Int, expectedLevel: UserExperience.Level, expectedAsset: String)] = [
    (-5, .egg, "egg"),
    (0,  .egg, "egg"),
    (9,  .egg, "egg"),
    (10, .chick, "chick"),
    (15, .chick, "chick"),
    (19, .chick, "chick"),
    (20, .hen, "hen"),
    (39, .hen, "hen"),
    (40, .phoenix, "phoenix"),
    (100, .phoenix, "phoenix")
  ]
  
  for (exp, expectedLevel, expectedAsset) in testCases {
    // 2. 도메인 모델 생성
    let domain = UserExperience(exp: exp)
    // 3. Realm 모델로 변환 (exp 필드만)
    let realmObj = RealmUserStatus()
    realmObj.exp = domain.exp
    
    // 4. 값 비교
    #expect(realmObj.exp == domain.exp)
    
    // 5. 레벨/이미지 매칭 검증
    #expect(domain.level == expectedLevel)
    #expect(domain.imageAssetName == expectedAsset)
    
  }
}

