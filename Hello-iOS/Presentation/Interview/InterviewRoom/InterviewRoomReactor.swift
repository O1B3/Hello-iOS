//
//  InterviewRoomReactor.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import Foundation

import ReactorKit
import RxSwift
import Speech
import RealmSwift
import RxRealm

final class InterviewRoomReactor: BaseReactor<
InterviewRoomReactor.Action,
InterviewRoomReactor.Mutation,
InterviewRoomReactor.State
> {
  // 사용자 액션 정의 (사용자의 의도)
  enum Action {
    case toggleRecording
    case recognizedTextChanged(String)
    case fetchQuestions
  }

  // 상태변경 이벤트 정의 (상태를 어떻게 바꿀 것인가)
  enum Mutation {
    case setRecording(Bool)
    case setRecognizedText(String)
    case setMyStudyQnAs([DomainQnA])              //  myStudy 데이터
    case setReviewRecords([MockInterviewRecord])  //  review 데이터
  }

  // View의 상태 정의 (현재 View의 상태값)
  struct State {
    var isRecording: Bool = false
    var recognizedText: String = ""
    var myStudyQnAs: [DomainQnA] = []
    var reviewRecords: [MockInterviewRecord] = []
  }

  // 생성자에서 초기 상태 설정
  let interviewMode: InterviewMode
  let realmService: RealmServiceType
  let learningService: LearningService

  init(realmService: RealmServiceType, interviewMode: InterviewMode, learningService: LearningService) {
    self.realmService = realmService
    self.interviewMode = interviewMode
    self.learningService = learningService
    super.init(initialState: State())
  }

  // Action이 들어왔을 때 어떤 Mutation으로 바뀔지 정의
  // 사용자 입력 → 상태 변화 신호로 변환
  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .toggleRecording:
      if currentState.isRecording {
        return .just(.setRecording(false))
      } else {
        requestPermissions()
        return .just(.setRecording(true))
      }
    case .recognizedTextChanged(let newText):
      return .just(.setRecognizedText(newText))
    case .fetchQuestions:
      let load: Observable<Mutation> = {
        switch interviewMode {
        case .myStudy(let categoryIDs):
          return Single<[DomainQnA]>.create { single in
            do {
              // 선택된 카테고리만 조회
              let predicate = NSPredicate(format: "id IN %@", categoryIDs)
              let realmCategories = try self.realmService.fetch(
                RealmCategory.self,
                predicate: predicate,
                sorted: []
              )

              // 학습한 데이터만 필터
              let memorizedConcepts: [RealmConcept] = realmCategories
                .flatMap { $0.concepts }
                .filter { $0.isMemory }

              // 컨셉들의 QnA를 평탄화 → Domain으로 매핑
              var qnas: [DomainQnA] = memorizedConcepts
                .flatMap { $0.qnas }
                .map { $0.toDomain() }

              // 랜덤으로 최대 10개
              qnas = Array(qnas.shuffled().prefix(10))

              single(.success(qnas))
            } catch {
              single(.failure(error))
            }
            return Disposables.create()
          }
          .map { Mutation.setMyStudyQnAs($0) }
          .asObservable()

        case .review(let records):
          return .just(.setReviewRecords(records))
        }
      }()
      return load
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
    case .setMyStudyQnAs(let qnas):
      newState.myStudyQnAs = qnas
    case .setReviewRecords(let records):
      newState.reviewRecords = records
    }
    return newState
  }

  // 마이크 권한 요청
  private func requestPermissions() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
      switch authStatus {
      case .authorized:
        print("음성 인식 권한 허용됨")
      case .denied:
        print("음성 인식 권한 거부됨")
      case .restricted:
        print("음성 인식이 이 디바이스에서 제한됨")
      case .notDetermined:
        print("음성 인식 권한 미결정")
      @unknown default:
        print("알 수 없는 상태")
      }
    }

    AVAudioSession.sharedInstance().requestRecordPermission { granted in
      print("마이크 권한: \(granted)")
    }
  }
}

