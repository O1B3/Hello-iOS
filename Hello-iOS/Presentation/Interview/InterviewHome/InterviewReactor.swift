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
    case setReviewQuestions([MockInterviewRecord])
  }

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    @Pulse var selectedMode: InterviewMode?
    var isReviewAvailable: Bool = false
    var reviewQuestions: [MockInterviewRecord] = []
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
        .map { $0.map { $0.toDomain() } }               // Realm → Domain 변환
        .flatMap { groups -> Observable<Mutation> in
          // 모든 기록 평탄화 후 불만족만 추출
          let unsatisfied = groups.flatMap { $0.records }.filter { !$0.isSatisfied }
          let picked = Array(unsatisfied.shuffled().prefix(10)) // 랜덤 최대 10개
          let hasAny = !picked.isEmpty

          // 두 개의 뮤테이션을 순차적으로 방출
          return Observable.concat([
            .just(.setReviewAvailable(hasAny)),
            .just(.setReviewQuestions(picked))
          ])
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
    case .setReviewQuestions(let records):
      newState.reviewQuestions = records
    }
    return newState
  }
}
