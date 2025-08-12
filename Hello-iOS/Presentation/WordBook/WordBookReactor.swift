//
//  WordBookReactor.swift
//  Hello-iOS
//
//  Created by seongjun cho on 8/7/25.
//

import Foundation

import ReactorKit
import RealmSwift
import RxSwift
import RxRealm

class WordBookReactor: BaseReactor<
    WordBookReactor.Action,
    WordBookReactor.Mutation,
    WordBookReactor.State
> {

  enum Action {
    case fetchWordBook
  }

  enum Mutation {
    case setWordBooks([DomainCategories])
  }

  struct State {
    var wordBooks: [DomainCategories] = []
  }

  let realmService: RealmServiceType

  init(realmService: RealmServiceType) {
    self.realmService = realmService
    super.init(initialState: State())
  }

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
    }
  }

  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setWordBooks(let books):
        newState.wordBooks = books
    }
    return newState
  }
}
