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


  private let questionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
  }

  private let verticalBar = UIView().then {
    $0.backgroundColor = .main
    $0.layer.cornerRadius = 2
    $0.clipsToBounds = true
  }

  private let questionLable = UILabel().then {
    $0.textColor = .label
    $0.numberOfLines = 0
    $0.backgroundColor = .clear
    $0.font = .systemFont(ofSize: 23, weight: .bold)
    $0.text = "Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요."
  }

  private let interviewerImageView = UIImageView().then {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
    $0.image = UIImage(systemName: "person", withConfiguration: config)
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 50
    $0.tintColor = .main
    $0.backgroundColor = .card
    $0.clipsToBounds = true
  }

  private let myAnswerTextView = UITextView().then {
    $0.textColor = .label
    $0.backgroundColor = .clear
    $0.font = .systemFont(ofSize: 23, weight: .medium)
    $0.text = "Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요 Array에 대해서 설명해주세요."
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
    questionStackView.addArrangedSubview(questionLable)
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
      $0.top.equalTo(questionStackView.snp.bottom).offset(12)
      $0.centerX.equalToSuperview()
      $0.height.width.equalTo(100)
    }

    myAnswerTextView.snp.makeConstraints {
      $0.top.equalTo(interviewerImageView.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    micStackView.snp.makeConstraints {
      $0.top.equalTo(myAnswerTextView.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
    }

  }
  override func bind(reactor: InterviewRoomReactor) {
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
        } else {
          self?.stopRecording()
        }
      })
      .disposed(by: disposeBag)
  }

  private func startRecording() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
      guard authStatus == .authorized else {
        print("음성 인식 권한 거부됨")
        return
      }

      DispatchQueue.main.async {
        if self.audioEngine.isRunning {
          self.audioEngine.stop()
          self.recognitionRequest?.endAudio()
          return
        }

        // 이전 작업 취소
        self.recognitionTask?.cancel()
        self.recognitionTask = nil

        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        do {
          try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
          try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
          print("오디오 세션 설정 실패: \(error.localizedDescription)")
          return
        }

        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = self.recognitionRequest else { return }

        let inputNode = self.audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
          if let result = result {
            let bestString = result.bestTranscription.formattedString
            self.reactor?.action.onNext(.recognizedTextChanged(bestString))
          }

          if error != nil || (result?.isFinal ?? false) {
            self.audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            self.recognitionRequest = nil
            self.recognitionTask = nil
          }
        }

        // 오디오 입력 설정
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
          self.recognitionRequest?.append(buffer)
        }

        self.audioEngine.prepare()
        do {
          try self.audioEngine.start()
        } catch {
          print("오디오 엔진 시작 실패: \(error.localizedDescription)")
        }
      }
    }
  }

  // 음성인식 중지
  private func stopRecording() {
    audioEngine.stop()
    recognitionRequest?.endAudio()
    recognitionRequest = nil
    recognitionTask = nil

    audioEngine.inputNode.removeTap(onBus: 0)
  }
}

