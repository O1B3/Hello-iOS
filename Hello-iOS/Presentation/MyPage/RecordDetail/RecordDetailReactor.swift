
import ReactorKit
import RxSwift

final class RecordDetailReactor: BaseReactor<
RecordDetailReactor.Action,
RecordDetailReactor.Mutation,
RecordDetailReactor.State
> {
  typealias Action = NoAction
  typealias Mutation = NoMutation

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    let items: [MockInterviewRecord]
  }
  
  // 생성자에서 초기 상태 설정
  init(items: [MockInterviewRecord]) {
    super.init(initialState: State(items: items))
  }

}
