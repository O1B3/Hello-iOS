
import Foundation

import ReactorKit
import RxSwift

final class MyRecordsReactor: BaseReactor<
MyRecordsReactor.Action,
MyRecordsReactor.Mutation,
MyRecordsReactor.State
> {
  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case sortByDate
    case selectGroup(String)
    case deleteGroup(String)
    case deleteAllGroups
  }
  
  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setGroups([MockInterviewGroup])
    case deleteOne(String)
    case deleteAll
    case selectedGroup(MockInterviewGroup?)
  }
  
  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    var recordGroups : [MockInterviewGroup] = []
    var cells : [RecordGroupCellVM] = []
    var selectedGroup: MockInterviewGroup? = nil
  }
  
  let recordDataService: RecordDataServiceProtocol
  
  private let dateFmt: DateFormatter = {
    let format = DateFormatter()
    format.dateFormat = "yyyy. MM. dd"
    format.locale = Locale(identifier: "ko_KR")
    return format
  }()
  
  // 생성자에서 초기 상태 설정
  init() {
    self.recordDataService = DIContainer.shared.resolve()
    super.init(initialState: State())
  }
  
  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .sortByDate:
      let groups = recordDataService.fetchinterViewGroups()
      return .just(.setGroups(groups))
      
    case let .selectGroup(id):
      let group = currentState.recordGroups.first(where: { $0.id == id})
      return .just(.selectedGroup(group))
      
    case let .deleteGroup(id):
      do {
        try recordDataService.deleteGroup(id: id)
        return .just(.deleteOne(id))
      } catch {
        return .empty()
      }
      
    case .deleteAllGroups:
      do {
        try recordDataService.deleteAll()
        return .just(.deleteAll)
      } catch {
        return .empty()
      }
    }
  }
  
  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .setGroups(groups):
      newState.recordGroups = groups
      newState.cells = groups.map { group in
        let satisfied = group.records.filter(\.isSatisfied).count
        let unsatisfied = group.records.count - satisfied
        return RecordGroupCellVM(
          id: group.id,
          dateText: dateFmt.string(from: group.date),
          satisfiedCount: satisfied,
          unsatisfiedCount: unsatisfied
        )
      }
    case let .deleteOne(id):
      newState.recordGroups.removeAll { $0.id == id }
      newState.cells.removeAll { $0.id == id }
      
    case .deleteAll:
      newState.recordGroups.removeAll()
      newState.cells.removeAll()
      
    case let .selectedGroup(group):
      newState.selectedGroup = group
    }
    
    return newState
  }
}
