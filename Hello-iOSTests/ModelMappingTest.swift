
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
  let groupId1 = UUID().uuidString
  let groupId2 = UUID().uuidString
  let now = Date()
  
  let record1 = MockInterviewRecord(
    id: 0,
    groupId: groupId1,
    question: "Q1?",
    modelAnswer: "A1",
    myAnswer: "MyA1",
    isSatisfied: true
  )
  let record2 = MockInterviewRecord(
    id: 1,
    groupId: groupId1,
    question: "Q2?",
    modelAnswer: "A2",
    myAnswer: "MyA2",
    isSatisfied: false
  )
  let record3 = MockInterviewRecord(
    id: 0,
    groupId: groupId2,
    question: "Q3?",
    modelAnswer: "A3",
    myAnswer: "MyA3",
    isSatisfied: false
  )
  

  // 2. 그룹(도메인) 생성
  let domain1 = MockInterviewGroup(id: groupId1, date: now, records: [record1, record2])
  let domain2 = MockInterviewGroup(id: groupId2, date: now, records: [record3])
  
  // 3. Realm 모델로 변환
  let realmObj1 = RealmMockInterviewGroup(from: domain1)
  let realmObj2 = RealmMockInterviewGroup(from: domain2)
  
  // 4. Realm → 도메인
  let mappedBack1 = realmObj1.toDomain()
  let mappedBack2 = realmObj2.toDomain()
  
  // 5.레코드 그룹아이디에 맞춰서 records가 왔는지 비교
  #expect(mappedBack1.records.count == 2)
  #expect(mappedBack2.records.count == 1)
  
  // 6. 값 비교
  #expect(mappedBack1.id == domain1.id)
  #expect(mappedBack1.date.timeIntervalSince1970 == domain1.date.timeIntervalSince1970)
  #expect(mappedBack1.records.count == domain1.records.count)
  
  // 각 record 값도 동일한지 확인
  for (a, b) in zip(mappedBack1.records, domain1.records) {
    #expect(a.id == b.id)
    #expect(a.groupId == b.groupId)
    #expect(a.question == b.question)
    #expect(a.modelAnswer == b.modelAnswer)
    #expect(a.myAnswer == b.myAnswer)
    #expect(a.isSatisfied == b.isSatisfied)
  }
}

// 샘플 도메인 빌더
private func makeDomainSample() -> (DomainCategories, DomainCategories) {
  // Category 1
  let qna101a = DomainQnA(id: 1001, conceptId: 101, question: "Q-101-1", answer: "A-101-1", latestUpdate: Date())
  let qna101b = DomainQnA(id: 1002, conceptId: 101, question: "Q-101-2", answer: "A-101-2", latestUpdate: Date())
  let c101 = DomainConcept(id: 101, categoryId: 1, concept: "C101", explain: "E101", latestUpdate: Date(), isMemory: false, qnas: [qna101a, qna101b])

  let qna102a = DomainQnA(id: 1003, conceptId: 102, question: "Q-102-1", answer: "A-102-1", latestUpdate: Date())
  let c102 = DomainConcept(id: 102, categoryId: 1, concept: "C102", explain: "E102", latestUpdate: Date(), isMemory: true, qnas: [qna102a])

  let cat1 = DomainCategories(id: 1, category: "iOS", concepts: [c101, c102])

  // Category 2
  let qna201a = DomainQnA(id: 2001, conceptId: 201, question: "Q-201-1", answer: "A-201-1", latestUpdate: Date())
  let c201 = DomainConcept(id: 201, categoryId: 2, concept: "C201", explain: "E201", latestUpdate: Date(), isMemory: false, qnas: [qna201a])

  let qna202a = DomainQnA(id: 2002, conceptId: 202, question: "Q-202-1", answer: "A-202-1", latestUpdate: Date())
  let c202 = DomainConcept(id: 202, categoryId: 2, concept: "C202", explain: "E202", latestUpdate: Date(), isMemory: false, qnas: [qna202a])

  let cat2 = DomainCategories(id: 2, category: "CS", concepts: [c201, c202])
  return (cat1, cat2)
}

// testRealmLearningDat 테스트 (빠른 unmanaged 매핑/필터 검증)
@Test
func testRealmLearningData_MappingAndFilter_NoRealm() throws {
  // 1) 도메인 샘플
  let (cat1Domain, cat2Domain) = makeDomainSample()

  // 2) Realm 객체로 매핑
  let rCat1 = RealmCategory(from: cat1Domain)
  let rCat2 = RealmCategory(from: cat2Domain)

  // - cat1의 concepts에 "categoryId = 2"인 이질 데이터 추가
  let foreignConceptForCat1 = RealmConcept(
    from: DomainConcept(id: 999, categoryId: 2, concept: "FOREIGN", explain: "FOREIGN", latestUpdate: Date(), isMemory: false, qnas: [])
  )
  rCat1.concepts.append(foreignConceptForCat1)

  // - cat1의 concept(101) qnas에 "conceptId = 999"인 이질 QnA 추가
  if let rC101 = rCat1.concepts.first(where: { $0.id == 101 }) {
    let foreignQnaForC101 = RealmQnA(
      from: DomainQnA(id: 5555, conceptId: 999, question: "FOREIGN-Q", answer: "FOREIGN-A", latestUpdate: Date())
    )
    rC101.qnas.append(foreignQnaForC101)
  }

  // 4) toDomain 호출 (filter가 FK처럼 거를 수 있어야 함)
  let mappedCat1 = rCat1.toDomain()
  let mappedCat2 = rCat2.toDomain()

  // 5) 카테고리 기본 필드
  #expect(mappedCat1.id == 1)
  #expect(mappedCat1.category == "iOS")
  #expect(mappedCat2.id == 2)
  #expect(mappedCat2.category == "CS")

  // 6) cat1의 concepts: 원래 2개(101,102)만 남아야 함 (FOREIGN 제거)
  #expect(mappedCat1.concepts.count == 2)
  #expect(Set(mappedCat1.concepts.map { $0.id }) == Set([101, 102]))
  mappedCat1.concepts.forEach { concept in
    #expect(concept.categoryId == 1)
  }

  // 7) concept 101의 QnA: 원래 2개(1001,1002)만 남아야 함 (FOREIGN 5555 제외)
  if let c101 = mappedCat1.concepts.first(where: { $0.id == 101 }) {
    #expect(c101.qnas.count == 2)
    #expect(Set(c101.qnas.map { $0.id }) == Set([1001, 1002]))
    c101.qnas.forEach { q in
      #expect(q.conceptId == 101)
    }
  } else {
    #expect(Bool(false), "C101 should exist")
  }

  // 8) concept 102의 QnA: 1개(1003)
  if let c102 = mappedCat1.concepts.first(where: { $0.id == 102 }) {
    #expect(c102.qnas.count == 1)
    #expect(c102.qnas.first?.id == 1003)
    #expect(c102.qnas.first?.conceptId == 102)
  } else {
    #expect(Bool(false), "C102 should exist")
  }

  // 9) cat2는 간단 확인
  #expect(mappedCat2.concepts.count == 2)
  #expect(Set(mappedCat2.concepts.map { $0.id }) == Set([201, 202]))
  mappedCat2.concepts.forEach { concept in
    #expect(concept.categoryId == 2)
    concept.qnas.forEach { q in
      #expect(q.conceptId == concept.id)
    }
  }
}

// UserExperience과 레벨 패턴 매칭 테스트 (arguments 사용)
@Test(arguments: [
  (-5,  UserExperience.Level.egg,     "egg"),
  (0,   UserExperience.Level.egg,     "egg"),
  (9,   UserExperience.Level.egg,     "egg"),
  (10,  UserExperience.Level.chick,   "chick"),
  (15,  UserExperience.Level.chick,   "chick"),
  (19,  UserExperience.Level.chick,   "chick"),
  (20,  UserExperience.Level.hen,     "hen"),
  (29,  UserExperience.Level.hen,     "hen"),
  (30,  UserExperience.Level.phoenix, "phoenix"),
])
func testUserExperience_and_LevelPatternMatching(
  exp: Int,
  expectedLevel: UserExperience.Level,
  expectedAsset: String
) {
  // 1) 도메인 생성
  let domain = UserExperience(exp: exp)
  // 2) Realm 모델 (exp만 매핑)
  let realmObj = RealmUserStatus()
  realmObj.exp = domain.exp

  // 3) 값 검증
  #expect(realmObj.exp == domain.exp, "exp=\(exp)")

  // 4) 레벨/이미지 검증
  #expect(domain.level == expectedLevel, "exp=\(exp)")
  #expect(domain.imageAssetName == expectedAsset, "exp=\(exp)")
}



