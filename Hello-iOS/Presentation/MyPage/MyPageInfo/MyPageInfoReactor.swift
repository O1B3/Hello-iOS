
import Foundation

import ReactorKit
import RealmSwift
import RxSwift


final class MyPageInfoReactor: BaseReactor<
MyPageInfoReactor.Action,
MyPageInfoReactor.Mutation,
MyPageInfoReactor.State
> {
  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case reloadUserStatus // 유저 정보 리로드
    case reloadAttendance // 출석 정보 리로드
  }
  
  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setUserExperience(UserExperience?)
    case setAttendance([Attendance])
  }
  
  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    var userExp: UserExperience?              // 유저 경험치
    var attendedDayKeys: Set<String> = []     // 캘린더 마킹에 사용
  }
  
  let userDataService: FetchUserDataServiceProtocol
  
  // 생성자에서 초기 상태 설정
  init(dataService: FetchUserDataServiceProtocol) {
    self.userDataService = dataService
    super.init(initialState: State())
  }
  
  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .reloadUserStatus:
      let user = userDataService.fetchUserExp()
      return .just(.setUserExperience(user))
    case .reloadAttendance:
      let list = userDataService.fetchAttendance()
      return .just(.setAttendance(list))
    }
  }
  
  
  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .setUserExperience(user):
      newState.userExp = user
    case let .setAttendance(list):
      newState.attendedDayKeys = Set(
        list.filter(\.isAttendance).map { DateKeyService.makeKey(from: $0.date) }
//        list.filter(\.isAttendance).map { Calendar.current.startOfDay(for: $0.date) }
      )
    }
    return newState
  }
}

