import Foundation
import RealmSwift
import Testing

@testable import Hello_iOS // 모듈명에 맞게 교체하세요

// MARK: - Test Helpers

func makeService() -> RealmService {
  let cfg = Realm.Configuration(inMemoryIdentifier: "Test-\(UUID().uuidString)")
  return RealmService(config: cfg)
}

// MARK: - Attendance (PK: id[String])

@Suite("RealmService.Attendance")
struct AttendanceTests {
  @Test
  func insert_and_fetch() throws {
    let sut = makeService()
    let att = RealmAttendance()
    att.id = "A1"
    att.date = Date()
    att.isAttendance = true
    
    try sut.insert(att)
    
    let fetched: Results<RealmAttendance> = try sut.fetch(RealmAttendance.self)
    #expect(fetched.count == 1)
    #expect(fetched.first?.id == "A1")
    #expect(fetched.first?.isAttendance == true)
  }
  
  @Test
  func insert_duplicate_should_throw() throws {
    let sut = makeService()
    
    let a1 = RealmAttendance(); a1.id = "DUP"; a1.date = Date(); a1.isAttendance = true
    let a2 = RealmAttendance(); a2.id = "DUP"; a2.date = Date(); a2.isAttendance = false
    
    try sut.insert(a1)
    
    do {
      try sut.insert(a2) // 같은 PK
      Issue.record("Expected duplicate PK error, but insert succeeded.")
      #expect(false)
    } catch {
      // OK: 중복 PK 시 Realm이 throw
      #expect(true)
    }
  }
  
  @Test
  func update_by_primary_key() throws {
    let sut = makeService()
    let a = RealmAttendance(); a.id = "U1"; a.date = Date(); a.isAttendance = false
    try sut.insert(a)
    
    try sut.update(RealmAttendance.self, forPrimaryKey: "U1") { obj in
      obj.isAttendance = true
    }
    
    let got = try sut.find(RealmAttendance.self, forPrimaryKey: "U1")
    #expect(got?.isAttendance == true)
  }
  
  @Test
  func update_missing_should_throw_objectNotFound() throws {
    let sut = makeService()
    do {
      try sut.update(RealmAttendance.self, forPrimaryKey: "NOPE") { _ in }
      Issue.record("Expected objectNotFound, but update succeeded.")
      #expect(false)
    } catch let e as RealmServiceError {
      #expect(e == .objectNotFound)
    } catch {
      Issue.record("Unexpected error: \(error)")
      #expect(false)
    }
  }
  
  @Test
  func delete_single_and_bulk() throws {
    let sut = makeService()
    let a1 = RealmAttendance(); a1.id = "D1"; a1.date = Date(); a1.isAttendance = true
    let a2 = RealmAttendance(); a2.id = "D2"; a2.date = Date(); a2.isAttendance = false
    try sut.insert([a1, a2])
    
    // 단건 삭제
    if let target = try sut.find(RealmAttendance.self, forPrimaryKey: "D1") {
      try sut.delete(target)
    }
    #expect((try sut.fetch(RealmAttendance.self)).count == 1)
    
    // 벌크 삭제(조건)
    let p = NSPredicate(format: "isAttendance == %@", NSNumber(booleanLiteral: false))
    try sut.deleteAll(RealmAttendance.self, predicate: p)
    #expect((try sut.fetch(RealmAttendance.self)).count == 0)
  }
}

// MARK: - MockInterview Group & Record (Group PK: id[String], Record: no PK)

@Suite("RealmService.MockInterview")
struct MockInterviewTests {
  @Test
  func create_group_and_append_record() throws {
    let sut = makeService()
    
    // 그룹 생성
    let g = RealmMockInterviewGroup()
    g.id = "G-1"
    g.date = Date()
    try sut.insert(g)
    
    // 레코드 추가 (그룹 내부 List에 append)
    try sut.update(RealmMockInterviewGroup.self, forPrimaryKey: "G-1") { group in
      let r = RealmMockInterviewRecord()
      r.id = 0
      r.groupId = group.id
      r.question = "Q1"
      r.modelAnswer = "A1"
      r.myAnswer = "B1"
      r.isSatisfied = false
      group.records.append(r)
    }
    
    let got = try sut.find(RealmMockInterviewGroup.self, forPrimaryKey: "G-1")
    #expect(got?.records.count == 1)
    #expect(got?.records.first?.question == "Q1")
  }
  
  @Test
  func toggle_record_satisfaction() throws {
    let sut = makeService()
    
    let g = RealmMockInterviewGroup()
    g.id = "G-2"; g.date = Date()
    let r = RealmMockInterviewRecord()
    r.id = 3; r.groupId = "G-2"; r.question = "Q"; r.modelAnswer = "A"; r.myAnswer = "B"; r.isSatisfied = false
    g.records.append(r)
    try sut.insert(g)
    
    try sut.update(RealmMockInterviewGroup.self, forPrimaryKey: "G-2") { group in
      if let rec = group.records.first(where: { $0.id == 3 }) {
        rec.isSatisfied.toggle()
      }
    }
    
    let got = try sut.find(RealmMockInterviewGroup.self, forPrimaryKey: "G-2")
    #expect(got?.records.first?.isSatisfied == true)
  }
  
  @Test
  func delete_group() throws {
    let sut = makeService()
    let g = RealmMockInterviewGroup(); g.id = "G-3"; g.date = Date()
    try sut.insert(g)
    if let grp = try sut.find(RealmMockInterviewGroup.self, forPrimaryKey: "G-3") {
      try sut.delete(grp)
    }
    #expect(try sut.find(RealmMockInterviewGroup.self, forPrimaryKey: "G-3") == nil)
  }
}

// MARK: - UserStatus (no PK, single row policy)

@Suite("RealmService.UserStatus")
struct UserStatusTests {
  @Test
  func create_once_and_update_all() throws {
    let sut = makeService()
    
    // 최초 1회 insert
    let u = RealmUserStatus()
    u.exp = 0
    try sut.insert(u)
    
    // 전체(사실상 1개)를 updateAll로 수정
    try sut.updateAll(RealmUserStatus.self, predicate: NSPredicate(value: true)) { obj in
      obj.exp = 40
    }
    
    let first = try sut.fetch(RealmUserStatus.self).first
    #expect(first?.exp == 40)
  }
  
  @Test
  func delete_all_user_status() throws {
    let sut = makeService()
    let u = RealmUserStatus(); u.exp = 10
    try sut.insert(u)
    try sut.deleteAll(RealmUserStatus.self, predicate: nil)
    #expect((try sut.fetch(RealmUserStatus.self)).isEmpty)
  }
}

// MARK: - LearningData (Category/Concept/QnA PK: Int)

@Suite("RealmService.LearningData")
struct LearningDataTests {
  @Test
  func insert_category_with_child_concept_and_qna() throws {
    let sut = makeService()
    
    // 카테고리
    let cat = RealmCategory()
    cat.id = 1
    cat.category = "iOS"
    
    // 컨셉
    let concept = RealmConcept()
    concept.id = 101
    concept.categoryId = 1
    concept.concept = "Realm"
    concept.explain = "Mobile database"
    concept.latestUpdate = Date()
    concept.isMemory = false
    
    // QnA
    let q = RealmQnA()
    q.id = 5001
    q.conceptId = 101
    q.question = "What is Realm?"
    q.answer = "A mobile database."
    q.latestUpdate = Date()
    
    concept.qnas.append(q)
    cat.concepts.append(concept)
    
    try sut.insert(cat)
    
    // 조회 및 검증
    let fetchedCat = try sut.find(RealmCategory.self, forPrimaryKey: 1)
    #expect(fetchedCat?.concepts.count == 1)
    #expect(fetchedCat?.concepts.first?.qnas.count == 1)
    #expect(fetchedCat?.concepts.first?.qnas.first?.question == "What is Realm?")
  }
  
  @Test
  func update_concept_memory_flag_and_delete_qna() throws {
    let sut = makeService()
    
    // 최소 데이터 구성
    let cat = RealmCategory()
    cat.id = 2; cat.category = "Swift"
    let concept = RealmConcept()
    concept.id = 201; concept.categoryId = 2
    concept.concept = "ARC"; concept.explain = "Memory"; concept.latestUpdate = Date(); concept.isMemory = false
    let q = RealmQnA(); q.id = 6001; q.conceptId = 201; q.question = "Q"; q.answer = "A"; q.latestUpdate = Date()
    concept.qnas.append(q); cat.concepts.append(concept)
    try sut.insert(cat)
    
    // isMemory 토글
    try sut.update(RealmConcept.self, forPrimaryKey: 201) { c in
      c.isMemory.toggle()
    }
    #expect(try sut.find(RealmConcept.self, forPrimaryKey: 201)?.isMemory == true)
    
    // QnA 제거
    try sut.update(RealmConcept.self, forPrimaryKey: 201) { c in
      if let idx = c.qnas.firstIndex(where: { $0.id == 6001 }) {
        c.qnas.remove(at: idx)
      }
    }
    #expect(try sut.find(RealmConcept.self, forPrimaryKey: 201)?.qnas.isEmpty == true)
  }
}
