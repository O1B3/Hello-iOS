//
//  InterviewRoomViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit
import Speech
import AVFoundation

class InterviewRoomViewController: BaseViewController<InterviewRoomReactor> {

  // 음성 인식 언어
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))

  // 음성인식 요청
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

  // 음성인식 요청결과
  private var recognitionTask: SFSpeechRecognitionTask?

  // 순수 소리만 인식하는 오디오 엔진
  private let audioEngine = AVAudioEngine()

  private let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil).then {
    $0.isEnabled = false
  }

  private let questionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
  }

  private let verticalBar = UIView().then {
    $0.backgroundColor = .main
    $0.layer.cornerRadius = 2
    $0.clipsToBounds = true
  }

  private let questionLabel = UILabel().then {
    $0.textColor = .label
    $0.numberOfLines = 0
    $0.backgroundColor = .clear
    $0.font = .systemFont(ofSize: 23, weight: .bold)
  }

  private let interviewerImageView = UIImageView().then {
    $0.image = .interviewer
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 75
    $0.tintColor = .main
    $0.backgroundColor = .card
    $0.clipsToBounds = true
  }

  private let myAnswerTextView = UITextView().then {
    $0.textColor = .label
    $0.backgroundColor = .clear
    $0.font = .systemFont(ofSize: 23, weight: .medium)
    $0.backgroundColor = .card
    $0.isEditable = false
    $0.layer.cornerRadius = 12
  }

  private let micStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 10
  }

  private let leftButton = UIButton(type: .system).then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
    $0.tintColor = .main
  }

  private let micButton = UIButton(type: .system).then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.setImage(UIImage(systemName: "mic", withConfiguration: config), for: .normal)
    $0.tintColor = .main
  }

  private let rightButton = UIButton(type: .system).then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
    $0.tintColor = .main
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "모의 면접"
    navigationItem.rightBarButtonItem = doneButton

    setupUI()
    setConstraints()
  }

  init(reactor: InterviewRoomReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  override func setupUI() {
    [questionStackView, interviewerImageView, myAnswerTextView, micStackView].forEach { view.addSubview($0) }
    questionStackView.addArrangedSubview(verticalBar)
    questionStackView.addArrangedSubview(questionLabel)
    micStackView.addArrangedSubview(leftButton)
    micStackView.addArrangedSubview(micButton )
    micStackView.addArrangedSubview(rightButton)


  }

  //  레이아웃 설정
  private func setConstraints() {
    questionStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.trailing.equalToSuperview().inset(32)
    }

    verticalBar.snp.makeConstraints {
      $0.width.equalTo(4)
    }

    interviewerImageView.snp.makeConstraints {
      $0.top.equalTo(questionStackView.snp.bottom).offset(40)
      $0.centerX.equalToSuperview()
      $0.height.width.equalTo(150)
    }

    myAnswerTextView.snp.makeConstraints {
      $0.top.equalTo(interviewerImageView.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    micStackView.snp.makeConstraints {
      $0.top.equalTo(myAnswerTextView.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(120)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
    }

  }
  override func bind(reactor: InterviewRoomReactor) {
    // 화면 진입 시 질문 로드
    rx.viewDidLoad
      .map { InterviewRoomReactor.Action.fetchQuestions }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    let currentIndex = BehaviorRelay<Int>(value: 0)   // 현재 보여주는 질문 인덱스
    let answers = BehaviorRelay<[String]>(value: [])  // 질문별 답변 저장소

    // 모드에 따라 질문 텍스트 배열을 스트림으로 준비
    let questions: Observable<[String]> = {
      switch reactor.interviewMode {
      case .myStudy:
        return reactor.state
          .map { $0.myStudyQnAs.map { $0.question } }
          .distinctUntilChanged()
      case .review:
        return reactor.state
          .map { $0.reviewRecords.map { $0.question } }
          .distinctUntilChanged()
      }
    }().share(replay: 1, scope: .whileConnected)

    // 데이터가 갱신되면 첫 질문을 보여주고 인덱스 초기화
    questions
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] qs in
        guard let self = self else { return }
        currentIndex.accept(0) // 첫 질문부터
        answers.accept(Array(repeating: "", count: qs.count)) // 질문 수만큼 빈 답변 배열
        self.questionLabel.text = qs.first ?? "질문이 없습니다."
        self.myAnswerTextView.text = "" // 첫 질문의 현재 답변 표시(초기엔 빈 문자열)
      })
      .disposed(by: disposeBag)

    // 음성 인식 결과 → 현재 인덱스의 답변 저장 + 텍스트 반영
    reactor.state
      .map { $0.recognizedText }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] text in
        guard let self = self else { return }
        self.myAnswerTextView.text = text // 화면 표시
        var arr = answers.value   // 배열에 저장
        let idx = currentIndex.value
        if arr.indices.contains(idx) { arr[idx] = text }
        answers.accept(arr)
      })
      .disposed(by: disposeBag)

    // 왼쪽(이전)
    leftButton.rx.tap
      .withLatestFrom(Observable.combineLatest(currentIndex.asObservable(), questions))
      .map { idx, qs in max(idx - 1, 0) }  // 음수 방지
      .withLatestFrom(Observable.combineLatest(questions, answers.asObservable())) { newIdx, pair in
        (newIdx, pair.0, pair.1) // (인덱스, 질문들, 답변들)
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] idx, qs, ans in
        guard let self = self else { return }
        currentIndex.accept(idx)
        self.questionLabel.text = qs.indices.contains(idx) ? qs[idx] : ""
        let saved = ans.indices.contains(idx) ? ans[idx] : ""
        self.myAnswerTextView.text = saved
        self.reactor?.action.onNext(.recognizedTextChanged(saved))
      })
      .disposed(by: disposeBag)

    // 오른쪽(다음)
    rightButton.rx.tap
      .withLatestFrom(Observable.combineLatest(currentIndex.asObservable(), questions))
      .map { idx, qs in min(idx + 1, max(qs.count - 1, 0)) }        // 상한 방지
      .withLatestFrom(Observable.combineLatest(questions, answers.asObservable())) { newIdx, pair in
        (newIdx, pair.0, pair.1)
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] idx, qs, ans in
        guard let self = self else { return }
        currentIndex.accept(idx)
        self.questionLabel.text = qs.indices.contains(idx) ? qs[idx] : ""
        let saved = ans.indices.contains(idx) ? ans[idx] : ""
        self.myAnswerTextView.text = saved
        self.reactor?.action.onNext(.recognizedTextChanged(saved))
      })
      .disposed(by: disposeBag)

    // 좌/우 버튼 활성화 상태 (처음엔 왼쪽 비활성, 마지막엔 오른쪽 비활성)
    Observable.combineLatest(
      currentIndex.asObservable(),
      questions.map { $0.count }.distinctUntilChanged(),
      reactor.state.map { $0.isRecording }.distinctUntilChanged()
    )
    .observe(on: MainScheduler.instance)
    .subscribe(onNext: { [weak self] idx, count, recording in
      guard let self = self else { return }
      self.leftButton.isEnabled = (idx > 0) && !recording
      self.rightButton.isEnabled = (idx + 1 < count) && !recording
    })
    .disposed(by: disposeBag)

    // --- Done 버튼 활성화: 마지막 페이지 && 모든 답변이 채워졌고 && 녹음 중 아님 ---
    let allAnswered = Observable
      .combineLatest(answers.asObservable(), questions.map { $0.count })
      .map { arr, count in
        guard arr.count == count, count > 0 else { return false }
        return arr.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      }
      .distinctUntilChanged()
      .share(replay: 1, scope: .whileConnected)

    Observable
      .combineLatest(
        currentIndex.asObservable(),
        questions.map { $0.count }.distinctUntilChanged(),
        reactor.state.map { $0.isRecording }.distinctUntilChanged(),
        allAnswered
      )
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] idx, count, recording, allOK in
        guard let self = self else { return }
        let isLast = (idx + 1 == count) && count > 0
        self.doneButton.isEnabled = isLast && allOK && !recording
      })
      .disposed(by: disposeBag)

    // Done 버튼 탭 시: 모든 답변 확인 후 진행 또는 알럿
    doneButton.rx.tap
      .withLatestFrom(Observable.combineLatest(
        answers.asObservable(),
        questions.map { $0.count },
        currentIndex.asObservable(),
        reactor.state.map { $0.isRecording }
      ))
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (arr: [String], count: Int, idx: Int, recording: Bool) in
        guard let self = self else { return }
        let trimmed = arr.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let unanswered = trimmed.enumerated().compactMap { i, t in t.isEmpty ? i : nil }

        let allOK = (arr.count == count) && unanswered.isEmpty

        // 녹음 중일 경우
        guard !recording else {
          self.presentSimpleAlert(title: "녹음 중", message: "녹음을 먼저 종료해주세요.")
          return
        }

        guard allOK else {
          let list = unanswered.map { "\($0 + 1)번" }.joined(separator: ", ")
          self.presentSimpleAlert(title: "답변하지 않은 문제가 있어요", message: "\(list)을(를) 완료하고 다시 시도해주세요.")
          return
        }

        // 모든 조건 통과시 결과 화면으로 이동
        let container = DIContainer.shared
        let realmService: RealmServiceType = container.resolve()
        let newGroupId = UUID().uuidString

        let records: [MockInterviewRecord]
        switch reactor.interviewMode {
        case .myStudy:
          let qnas = self.reactor!.currentState.myStudyQnAs
          records = qnas.enumerated().map { index, qna in
            let myAnswer = (index < trimmed.count) ? trimmed[index] : ""
            return MockInterviewRecord(
              id: index,
              groupId: newGroupId,
              question: qna.question,
              modelAnswer: qna.answer,
              myAnswer: myAnswer,
              isSatisfied: false
            )
          }

        case .review:
          let originalRecords = self.reactor!.currentState.reviewRecords
          records = originalRecords.enumerated().map { index, record in
            let myAnswer = (index < trimmed.count) ? trimmed[index] : record.myAnswer
            return MockInterviewRecord(
              id: record.id,
              groupId: record.groupId,
              question: record.question,
              modelAnswer: record.modelAnswer,
              myAnswer: myAnswer,
              isSatisfied: record.isSatisfied
            )
          }
        }

        // 3) Result 화면의 Reactor 생성 후 VC에 주입해서 push
        let resultReactor = ResultInterviewReactor(
          realmService: realmService,
          reslut: records
        )
        let resultVC = ResultInterviewViewController(reactor: resultReactor)
        self.navigationController?.pushViewController(resultVC, animated: true)
      })
      .disposed(by: disposeBag)

    micButton.rx.tap
      .map { InterviewRoomReactor.Action.toggleRecording}
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    reactor.state
      .map { $0.recognizedText }
      .distinctUntilChanged()
      .bind(to: myAnswerTextView.rx.text)
      .disposed(by: disposeBag)

    //녹음 상태가 바뀌면 start/stop 동작
    reactor.state
      .map { $0.isRecording }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isRecording in
        if isRecording {
          self?.startRecording()
          let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
          self?.micButton.setImage(UIImage(systemName: "record.circle", withConfiguration: config), for: .normal)
          self?.micButton.tintColor = .wrong
        } else {
          self?.stopRecording()
          let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
          self?.micButton.setImage(UIImage(systemName: "mic", withConfiguration: config), for: .normal)
          self?.micButton.tintColor = .main
        }
      })
      .disposed(by: disposeBag)
  }

  // 음성 인식 시작
  private func startRecording() {
    // 사용자의 음성 인식 권한 요청
    SFSpeechRecognizer.requestAuthorization { authStatus in
      // 권한이 승인되지 않으면 종료
      guard authStatus == .authorized else {
        print("음성 인식 권한 거부됨")
        return
      }

      DispatchQueue.main.async {
        // 이전에 진행 중이던 음성 인식 작업이 있다면 취소 및 초기화
        self.recognitionTask?.cancel()
        self.recognitionTask = nil

        // 오디오 세션 설정 (녹음 전용 모드로 설정)
        let audioSession = AVAudioSession.sharedInstance()
        do {
          // 녹음 모드, 측정 모드로 설정하고 다른 사운드는 작게 줄임
          try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
          // 오디오 세션 활성화 (다른 앱에도 알림)
          try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
          print("오디오 세션 설정 실패: \(error.localizedDescription)")
          return
        }

        // 음성 인식 요청 객체 생성 (실시간 스트리밍용)
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = self.recognitionRequest else { return }

        // 오디오 입력 노드 가져오기
        let inputNode = self.audioEngine.inputNode

        // 부분 결과도 받을 수 있도록 설정
        recognitionRequest.shouldReportPartialResults = true

        // 음성 인식 태스크 실행
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
          // 인식 결과가 있으면 최상의 텍스트를 reactor에 전달
          if let result = result {
            let bestString = result.bestTranscription.formattedString
            self.reactor?.action.onNext(.recognizedTextChanged(bestString))
          }

          // 오류가 발생하거나 인식이 완료되면 정리
          if error != nil || (result?.isFinal ?? false) {
            self.cleanupRecording()
          }
        }

        // 오디오 입력 설정: inputNode로부터 데이터를 받아서 recognitionRequest에 추가
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
          self.recognitionRequest?.append(buffer)
        }

        // 오디오 엔진 준비 및 시작
        self.audioEngine.prepare()
        do {
          try self.audioEngine.start()
        } catch {
          print("오디오 엔진 시작 실패: \(error.localizedDescription)")
        }
      }
    }
  }

  // 음성 인식 종료 및 관련 리소스 정리
  private func cleanupRecording() {
    audioEngine.stop() // 오디오 엔진 정지
    audioEngine.inputNode.removeTap(onBus: 0) // 입력 노드의 탭 제거
    recognitionRequest = nil // 요청 객체 해제
    recognitionTask = nil    // 태스크 객체 해제
  }

  // 외부에서 음성 인식을 중지할 때 호출되는 함수
  private func stopRecording() {
    recognitionRequest?.endAudio() // 더 이상 오디오 입력을 받지 않도록 설정
    cleanupRecording()             // 녹음 정리
  }

  private func presentSimpleAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}
