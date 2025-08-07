//
//  InterviewRoomReactor.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import ReactorKit
import RxSwift

final class InterviewRoomReactor: BaseReactor<
InterviewRoomReactor.Action,
InterviewRoomReactor.Mutation,
InterviewRoomReactor.State
> {
  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case toggleRecording
  }

  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setRecording(Bool)
    case setRecognizedText(String)
  }

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    var isRecording: Bool = false
    var recognizedText: String = ""
  }

  // 생성자에서 초기 상태 설정
  init() {
    super.init(initialState: State())
  }

  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .toggleRecording:
      if currentState.isRecording {
        return .concat([
          .just(.setRecording(false)),
          .just(.setRecognizedText("녹음 끝!")),
        ])
      } else {
        return .concat([
          .just(.setRecording(true)),
          .just(.setRecognizedText("녹음 시작!")),
        ])
      }
    }
  }

  // Mutation이 발생했을 때 상태(State)를 실제로 바꿈
  // 상태 변화 신호 → 실제 상태 반영
  override func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setRecording(let isRecording):
      newState.isRecording = isRecording
    case .setRecognizedText(let recognizedText):
      newState.recognizedText = recognizedText
    }
    return newState
  }
}

