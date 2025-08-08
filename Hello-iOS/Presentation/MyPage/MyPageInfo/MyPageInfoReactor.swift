
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
  }
  
  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setUserExperience(UserExperience?)
  }
  
  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    //    var profileImageName: String?  // 프로필 이미지 네임
    //    var levelText: String?         // 레벨 텍스트
    //    var expProgress: Float?        // 프로그레스 바 진행정도
    //    var expLabel: String?          // 경험치 라벨
    var userExp: UserExperience?
  }
  
  let userDataService: FetchUserDataServiceProtocol
  
  // 생성자에서 초기 상태 설정
  init(dataService: FetchUserDataServiceProtocol) {
    self.userDataService = dataService
    //    let user = userDataService.fetchUserExp()
    //    let (expProgress, expLabel) = user.expProgressAndLabel()
    
    super.init(initialState: State())
  }
  
  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .reloadUserStatus:
      let user = userDataService.fetchUserExp()
      return .just(.setUserExperience(user))
    }
  }
  
  
  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .setUserExperience(user):
      newState.userExp = user
    }
    return newState
  }
}

