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

  private let questions = [
    ("질문 1", "모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1모범답안 1", "내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1내 답변 1"),
    ("질문 2", "모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2모범답안 2", "내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2내 답변 2")
  ]


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

  override func bind(reactor _: ResultInterviewReactor) {
    correctButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.cardStack.swipe(.right, animated: true)
      }
      .disposed(by: disposeBag)

    wrongButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.cardStack.swipe(.left, animated: true)
      }
      .disposed(by: disposeBag)

    doneButton.rx.tap
      .withUnretained(self)
      .bind(with: self) { owner, _ in
          if let nav = owner.navigationController {
            // 현재 내비게이션 스택의 루트 화면으로 한 번에 복귀
            nav.popToRootViewController(animated: true)
          } else {
            // 만약 모달로 떠 있었다면 모달 닫기
            owner.presentingViewController?.dismiss(animated: true, completion: nil)
          }
        }
        .disposed(by: disposeBag)
  }
}

extension ResultInterviewViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
  // 카드 수
  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return questions.count
  }

  // 카드 셀 구성
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    let card = SwipeCard()
    card.layer.cornerRadius = 12
    card.layer.masksToBounds = true
    card.layer.shadowOpacity = 0.2

    // 커스텀 내용 뷰 구성
    let view = ResultCardView()
    let q = questions[index]
    view.configure(question: q.0, modelAnswer: q.1, myAnswer: q.2)

    // 손가락 스와이프 비활성화 (버튼으로만 동작)
    card.panGestureRecognizer.isEnabled = false

    card.content = view

    return card
  }

  // 이벤트 처리
  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    if direction == .left {
      print("❌ \(questions[index].0) - 불만족")
    } else if direction == .right {
      print("✅ \(questions[index].0) - 만족")
    }
  }

  func didSwipeAllCards(_ cardStack: SwipeCardStack) {
    print("모든 카드 소진됨")
    doneButton.isEnabled = true
  }

}
