//
//  InterviewReactor.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//
import Foundation

import ReactorKit
import RealmSwift
import RxSwift
import RxRealm

final class InterviewReactor: BaseReactor<
InterviewReactor.Action,
InterviewReactor.Mutation,
InterviewReactor.State
> {

  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case selectInterviewMode(InterviewMode)
    case fetchInterviewRecord
  }

  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setMode(InterviewMode)
    case setReviewAvailable(Bool)
  }

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    @Pulse var selectedMode: InterviewMode?
    var isReviewAvailable: Bool = false
  }

  let realmService: RealmServiceType

  init(realmService: RealmServiceType) {
    self.realmService = realmService
    super.init(initialState: State())
  }

  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .selectInterviewMode(let mode):
      return .just(.setMode(mode))
    case .fetchInterviewRecord:
      guard let results = try? realmService.fetch(
        RealmMockInterviewGroup.self,
        predicate: nil,
        sorted: [SortDescriptor(keyPath: "date", ascending: false)]
      ) else {
        return .empty()
      }

      return Observable.collection(from: results)
        .map { newResults in
          // Realm 객체 -> 도메인 변환
          let groups = newResults.map { $0.toDomain() }

          // 불만족 데이터가 1개 이상 있는지 판단
          let hasAnyUnsatisfied = groups.contains { group in
            group.records.contains { !$0.isSatisfied }
          }

          return .setReviewAvailable(hasAnyUnsatisfied)
        }
    }
  }

  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setMode(let mode):
      newState.selectedMode = mode
    case .setReviewAvailable(let flag):
      newState.isReviewAvailable = flag
    }
    return newState
  }
}
