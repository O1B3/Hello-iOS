//
//  ResultInterviewReactor.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import Foundation

import ReactorKit
import RxSwift
import RealmSwift


final class ResultInterviewReactor: BaseReactor<
ResultInterviewReactor.Action,
ResultInterviewReactor.Mutation,
ResultInterviewReactor.State
> {
  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case toggleSatisfied(Int)               // 인덱스의 만족/불만족 토글
    case swipe(index: Int, satisfied: Bool)
    case save                               // 결과 저장
  }

  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case updateRecords([MockInterviewRecord]) // 토글 반영
    case setIndex(Int)
    case setSaving(Bool)
    case setSaved(Bool)                       // 저장 완료
  }

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    var records: [MockInterviewRecord] = []  // 표시할 결과 (질문/모범답/내답)
    var isSaving: Bool = false
    var isSaved: Bool = false

    var currentIndex: Int = 0
    var totalCount: Int { records.count }
    var satisfiedCount: Int { records.filter { $0.isSatisfied }.count }
    var unsatisfiedCount: Int { totalCount - satisfiedCount }
    var progress: Double { totalCount > 0 ? Double(currentIndex) / Double(totalCount) : 0 }
    var canSave: Bool { currentIndex >= totalCount && totalCount > 0 && !isSaving }
  }

  // 생성자에서 초기 상태 설정
  let realmService: RealmServiceType

  init(realmService: RealmServiceType, reslut: [MockInterviewRecord]) {
    self.realmService = realmService
    super.init(initialState: State(records: reslut))
  }

  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .toggleSatisfied(let index):
      var newRecords = currentState.records
      if newRecords.indices.contains(index) {
        // 만족도 토글
        let record = newRecords[index]
        let toggled = MockInterviewRecord(
          id: record.id,
          groupId: record.groupId,
          question: record.question,
          modelAnswer: record.modelAnswer,
          myAnswer: record.myAnswer,
          isSatisfied: !record.isSatisfied
        )
        newRecords[index] = toggled
      }
      return .just(.updateRecords(newRecords))

    case let .swipe(index, satisfied):
      var updated = currentState.records
      if updated.indices.contains(index) {
        let old = updated[index]
        if old.isSatisfied != satisfied {
          updated[index] = MockInterviewRecord(
            id: old.id,
            groupId: old.groupId,
            question: old.question,
            modelAnswer: old.modelAnswer,
            myAnswer: old.myAnswer,
            isSatisfied: satisfied
          )
        }
      }
      let nextIndex = min(currentState.currentIndex + 1, updated.count)
        return Observable.concat([
          .just(.updateRecords(updated)),
          .just(.setIndex(nextIndex))
        ])

    case .save:
      // 저장 시작 → Realm에 그룹/레코드 저장
      return Observable.concat([
        .just(.setSaving(true)),
        saveToRealm(records: currentState.records)
          .map { Mutation.setSaved($0) },
        .just(.setSaving(false))
      ])
    }
  }

  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .updateRecords(let records):
      newState.records = records
    case .setIndex(let idx):
      newState.currentIndex = idx
    case .setSaving(let isSaving):
      newState.isSaving = isSaving
    case .setSaved(let ok):
      newState.isSaved = ok
    }
    return newState
  }

  private func saveToRealm(records: [MockInterviewRecord]) -> Observable<Bool> {
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onNext(false); observer.onCompleted(); return Disposables.create()
      }

      do {
        guard let groupId = records.first?.groupId else {
          observer.onNext(false); observer.onCompleted(); return Disposables.create()
        }

        let group = RealmMockInterviewGroup()
        group.id = groupId
        group.date = Date()

        let realmRecords = records.map { record -> RealmMockInterviewRecord in
          let realmRecord = RealmMockInterviewRecord()
          realmRecord.id = record.id
          realmRecord.groupId = record.groupId
          realmRecord.question = record.question
          realmRecord.modelAnswer = record.modelAnswer
          realmRecord.myAnswer = record.myAnswer
          realmRecord.isSatisfied = record.isSatisfied
          return realmRecord
        }
        group.records.append(objectsIn: realmRecords)

        try self.realmService.write { realm in
          if let existed = realm.object(ofType: RealmMockInterviewGroup.self, forPrimaryKey: groupId) {
            realm.delete(existed.records)
            realm.delete(existed)
          }
          realm.add(group, update: .modified)
        }

        observer.onNext(true)
        observer.onCompleted()
      } catch {
        // 에러 메시지 노출은 안 하기로 했으므로 false만 반환
        observer.onNext(false)
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}

