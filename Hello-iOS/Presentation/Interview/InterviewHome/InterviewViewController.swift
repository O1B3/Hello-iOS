//
//  InterViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//
import UIKit
import ReactorKit
import RxCocoa
import Then
import SnapKit

class InterviewViewController: BaseViewController<InterviewReactor> {

  private let buttonStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 24
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.clipsToBounds = false
    $0.layer.masksToBounds = false
  }

  private let myStudyInterviewButton = SelectButton().then {
    $0.configure(
      title: "내 학습 기반\n모의 면접",
      subtitle: "등록한 단어·질문으로 테스트",
      iconName: "graduationcap.fill",
      backgroundColor: UIColor.main
    )
  }

  private let reviewInterviewButton = SelectButton().then {
    $0.configure(
      title: "복습 모의 면접",
      subtitle: "불만족 질문 다시 도전",
      iconName: "arrow.clockwise",
      backgroundColor: UIColor.sub
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "모의 면접 시작하기"
    setupUI()
    setConstraints()
  }

  init(reactor: InterviewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 추가
  override func setupUI() {
    view.addSubview(buttonStackView)
    buttonStackView.addArrangedSubview(myStudyInterviewButton)
    buttonStackView.addArrangedSubview(reviewInterviewButton)
  }

  //  레이아웃 설정
  private func setConstraints() {
    buttonStackView.snp.makeConstraints {
      $0.top.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
  }

  override func bind(reactor: InterviewReactor) {
    myStudyInterviewButton.rx.tap
      .map { InterviewReactor.Action.selectInterviewMode(.myStudy) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    reviewInterviewButton.rx.tap
      .map { InterviewReactor.Action.selectInterviewMode(.review) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    reactor.pulse(\.$selectedMode)
      .bind(with: self) { owner, mode in
        let container = DIContainer.shared
        // container.register(SelectionInterviewViewController(
        //   mode: mode,
        //   reactor: SelectionInterviewViewReactor())
        // )
        container.register(InterviewRoomViewController(reactor: InterviewRoomReactor()))
        let interviewRoomVC: InterviewRoomViewController = container.resolve()
        owner.navigationController?.pushViewController(interviewRoomVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
}

