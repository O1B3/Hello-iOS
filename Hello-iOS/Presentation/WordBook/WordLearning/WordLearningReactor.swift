//
//  WordLearningReactor.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import Foundation

import ReactorKit
import RealmSwift
import RxSwift
import RxRealm

class WordLearningReactor: BaseReactor<
WordLearningReactor.Action,
WordLearningReactor.Mutation,
WordLearningReactor.State
> {

  let realmService: RealmServiceType

  enum Action {
    case memorize(Int, Bool)
    case addContent(String, String, String, String)
  }

  enum Mutation {
    case updateConcepts([DomainConcept])
  }

  struct State {
    var concepts: [DomainConcept]
  }

  init(realmService: RealmServiceType, concepts: [DomainConcept]) {
    self.realmService = realmService
    super.init(initialState: State(concepts: concepts))
  }

  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .memorize(let index, let isMemorize):
      do {
        try realmService.update(
          RealmConcept.self,
          forPrimaryKey: currentState.concepts[index].id) {
            $0.isMemory = isMemorize
          }

        var updatedConcepts = currentState.concepts
        if index < updatedConcepts.count {
            updatedConcepts[index].isMemory = isMemorize
        } else {
            // Handle the case where index is out of bounds, though it should ideally not happen
            print("Error: Index out of bounds in WordLearningReactor.mutate for memorize action")
        }
        return .just(.updateConcepts(updatedConcepts))
      } catch {
        print(error)
        return .empty()
      }
    case .addContent(let concept, let explain, let question, let answer):
      do {
        let conceptNum = try realmService.fetch(
          RealmConcept.self,
          predicate: nil,
          sorted: [SortDescriptor(keyPath: "id", ascending: true)]
        ).count

        let qnaNum = try realmService.fetch(
          RealmQnA.self,
          predicate: nil,
          sorted: [SortDescriptor(keyPath: "id", ascending: true)]
        ).count

        let domainQnA = DomainQnA(
          id: -qnaNum,
          conceptId: -conceptNum,
          question: question,
          answer: answer,
          latestUpdate: Date()
        )

        let doaminConcepts = DomainConcept(
          id: -conceptNum,
          categoryId: Int(self.currentState.concepts.first?.categoryId ?? 0),
          concept: concept,
          explain: explain,
          latestUpdate: Date(),
          qnas: [domainQnA]
        )

        try realmService.update(RealmCategory.self, forPrimaryKey: doaminConcepts.categoryId) {
          $0.concepts.append(RealmConcept(from: doaminConcepts))
        }
      } catch {
        print(error)
      }
      return .empty()
    }
  }

  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .updateConcepts(let concepts):
      newState.concepts = concepts
    }
    return newState
  }
}
