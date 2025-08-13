//
//  ResultInterviewViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/7/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit
import Shuffle

class ResultInterviewViewController: BaseViewController<ResultInterviewReactor> {

  private let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil).then {
    $0.isEnabled = false
  }

  // 진행 상황 스택 뷰
  private let processStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.distribution = .fillEqually
  }

  // 진행률 원형 링
  private let ring = RingView().then {
    $0.trackColor = .systemGray
    $0.progressColor = .main
    $0.lineWidth = 6
    $0.setCenterText("3/10")
    $0.setProgress(0.3, animated: true)
  }

  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .fillEqually

    $0.spacing = 10
  }

  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.spacing = 5
  }

  private let contentTitle = UILabel().then {
    $0.textColor = .correct
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "만　족 : "
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }

  private let contentText = UILabel().then {
    $0.textColor = .correct
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "3"
  }

  private let wrongStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.spacing = 5
  }

  private let wrongTitle = UILabel().then {
    $0.textColor = .wrong
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "불만족 : "
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
  }

  private let wrongText = UILabel().then {
    $0.textColor = .wrong
    $0.font = .systemFont(ofSize: 22, weight: .bold)
    $0.text = "0"
  }

  private let cardStack = SwipeCardStack().then {
    $0.backgroundColor = .card
    $0.layer.cornerRadius = 20
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 3
    $0.layer.shadowOpacity = 0.35
  }

  private let buttonStack = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fillEqually
    $0.spacing = 24
  }

  private let correctButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "checkmark"), for: .normal)
    $0.tintColor = .correct
    $0.layer.cornerRadius = 14
    $0.layer.borderWidth = 2
    $0.layer.borderColor = UIColor.correct.cgColor
  }

  private let wrongButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .wrong
    $0.layer.cornerRadius = 14
    $0.layer.borderWidth = 2
    $0.layer.borderColor = UIColor.wrong.cgColor
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "모의 면접 결과"
    navigationItem.rightBarButtonItem = doneButton
    setupUI()
    setConstraints()

    cardStack.dataSource = self
    cardStack.delegate = self

    cardStack.reloadData()

  }

  init(reactor: ResultInterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  override func setupUI() {
    view.addSubview(processStackView)
    processStackView.addArrangedSubview(ring)
    processStackView.addArrangedSubview(textStackView)

    textStackView.addArrangedSubview(contentStackView)
    textStackView.addArrangedSubview(wrongStackView)

    contentStackView.addArrangedSubview(contentTitle)
    contentStackView.addArrangedSubview(contentText)

    wrongStackView.addArrangedSubview(wrongTitle)
    wrongStackView.addArrangedSubview(wrongText)

    view.addSubview(cardStack)
    view.addSubview(buttonStack)

    buttonStack.addArrangedSubview(correctButton)
    buttonStack.addArrangedSubview(wrongButton)

  }

  //  레이아웃 설정
  private func setConstraints() {
    processStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    ring.snp.makeConstraints {
      $0.width.height.equalTo(100)
    }

    cardStack.snp.makeConstraints {
      $0.top.equalTo(processStackView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
    }

    buttonStack.snp.makeConstraints {
      $0.top.equalTo(cardStack.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(32)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
    }

    correctButton.snp.makeConstraints {
      $0.height.equalTo(100)
    }

    wrongButton.snp.makeConstraints {
      $0.height.equalTo(100)
    }
  }

  override func bind(reactor: ResultInterviewReactor) {
    let currentIndex = reactor.state
      .map(\.currentIndex)
      .distinctUntilChanged()
      .share(replay: 1)

    correctButton.rx.tap
      .withLatestFrom(currentIndex)
      .do(onNext: { [weak self] _ in
        self?.reactor?.action.onNext(.swipe(index: self?.reactor?.currentState.currentIndex ?? 0, satisfied: true))
        self?.cardStack.swipe(.right, animated: true)
      })
      .subscribe()
      .disposed(by: disposeBag)

    wrongButton.rx.tap
      .withLatestFrom(currentIndex)
      .do(onNext: { [weak self] _ in
        self?.reactor?.action.onNext(.swipe(index: self?.reactor?.currentState.currentIndex ?? 0, satisfied: false))
        self?.cardStack.swipe(.left, animated: true)
      })
      .subscribe()
      .disposed(by: disposeBag)

    reactor.state
      .subscribe(onNext: { [weak self] state in
        guard let self = self else { return }
        self.contentText.text = "\(state.satisfiedCount)"
        self.wrongText.text = "\(state.unsatisfiedCount)"
        self.ring.setCenterText("\(state.currentIndex)/\(state.totalCount)")
        self.ring.setProgress(CGFloat(state.progress), animated: true)
        self.doneButton.isEnabled = state.canSave
      })
      .disposed(by: disposeBag)

    // 저장
    doneButton.rx.tap
      .map { ResultInterviewReactor.Action.save }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 저장 완료 시 알림 후 닫기
    reactor.state
      .map(\.isSaved)
      .filter { $0 }
      .take(1)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        let alert = UIAlertController(title: "저장 완료", message: "저장이 완료되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
          if let nav = self.navigationController {
            nav.popToRootViewController(animated: true)
          } else {
            self.presentingViewController?.dismiss(animated: true)
          }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
}

extension ResultInterviewViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
  // 카드 수
  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return reactor?.currentState.records.count ?? 0
  }

  // 카드 셀 구성
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    let card = SwipeCard()
    card.layer.cornerRadius = 12
    card.layer.masksToBounds = true
    card.layer.shadowOpacity = 0.2

    let view = ResultCardView()
    if let items = reactor?.currentState.records, index >= 0, index < items.count {
      let item = items[index]
      view.configure(question: item.question, modelAnswer: item.modelAnswer, myAnswer: item.myAnswer)
    }

    // 손가락 스와이프 비활성화 (버튼으로만 동작)
    card.panGestureRecognizer.isEnabled = false
    card.content = view
    return card
  }

  // 이벤트 처리
  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    if direction == .left {
      print("❌ \(index) - 불만족")
    } else if direction == .right {
      print("✅ \(index) - 만족")
    }
  }
}
