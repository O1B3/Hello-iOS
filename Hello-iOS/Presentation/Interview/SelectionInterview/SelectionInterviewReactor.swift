//
//  SelectionInterviewReactor.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import Foundation

import ReactorKit
import RxSwift
import RealmSwift
import RxRealm

final class SelectionInterviewReactor: BaseReactor<
SelectionInterviewReactor.Action,
SelectionInterviewReactor.Mutation,
SelectionInterviewReactor.State
> {
  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case fetchWordBook
    case selectCategory(Int)    // 카테고리 선택
    case deselectCategory(Int)  // 카테고리 해제
  }

  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setWordBooks([DomainCategories])
    case setSelectedIDs(Set<Int>)
  }

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    var wordBooks: [DomainCategories] = []
    var selectedIDs: Set<Int> = []
  }

  let realmService: RealmServiceType

  // 생성자에서 초기 상태 설정
  init(realmService: RealmServiceType) {
    self.realmService = realmService
    super.init(initialState: State())
  }

  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchWordBook:
      guard let results = try? realmService.fetch(
        RealmCategory.self,
        predicate: nil,
        sorted: [SortDescriptor(keyPath: "id", ascending: false)]
      ) else {
        return .empty()
      }
      return Observable.collection(from: results)
        .map { newResults in
          let domainBooks = newResults.map { $0.toDomain() }
          return .setWordBooks(Array(domainBooks))
        }

    case .selectCategory(let id):
      var newSet = currentState.selectedIDs
      newSet.insert(id)
      return .just(.setSelectedIDs(newSet))

    case .deselectCategory(let id):
      var newSet = currentState.selectedIDs
      newSet.remove(id)
      return .just(.setSelectedIDs(newSet))
    }
  }

  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setWordBooks(let books):
      newState.wordBooks = books

    case .setSelectedIDs(let ids):
      newState.selectedIDs = ids
    }
    return newState
  }
}
