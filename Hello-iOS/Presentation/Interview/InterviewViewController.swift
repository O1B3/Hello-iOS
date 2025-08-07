//
//  InterViewController.swift
//  Hello-iOS
//
//  Created by 이태윤 on 8/6/25.
//

import UIKit
import ReactorKit
import Then
import SnapKit

class InterviewViewController: BaseViewController<InterviewReactor> {

  let buttonStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 24
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.clipsToBounds = false
    $0.layer.masksToBounds = false
  }

  let myStudyInterviewButton = ShadowButton().then {
    $0.setTitle("내 학습 기반 모의 면접", for: .normal)
  }

  let reviewInterviewButton = ShadowButton().then {
    $0.setTitle("복습 모의 면접", for: .normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
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
  private func setUI() {
    view.addSubview(buttonStackView)
    buttonStackView.addArrangedSubview(myStudyInterviewButton)
    buttonStackView.addArrangedSubview(reviewInterviewButton)
  }

  //  레이아웃 설정
  private func setConstraints() {
    buttonStackView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
  }
}

